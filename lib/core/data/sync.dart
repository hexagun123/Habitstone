/// This file contains the core logic for two-way data synchronization between
/// the local Hive database and the remote Firebase Firestore database. The `FirebaseSync`
/// class manages fetching data, listening for real-time updates, and pushing local
/// changes to the cloud.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart'; // Needed for BoxEvent
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';
import 'hive.dart';

/// A service class that orchestrates data synchronization with Firebase Firestore.
/// It handles both pulling initial data and maintaining real-time updates.
class FirebaseSync {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HiveRepository _hiveRepo;

  // A flag to prevent sync loops. When true, local Hive listeners should ignore
  // changes, as they are being initiated by a server operation.
  bool _isPerformingServerOperation = false;

  // Holds all active stream subscriptions (both Firebase and Hive) to be cancelled later.
  final List<StreamSubscription> _subscriptions = [];

  FirebaseSync(this._hiveRepo);

  /// A private getter for the currently authenticated Firebase user.
  User? get _user => _auth.currentUser;

  /// A helper method to get a reference to a user-specific Firestore collection.
  /// Throws an exception if no user is logged in.
  CollectionReference<Map<String, dynamic>> _collection(String name) {
    if (_user == null) throw Exception("User not logged in.");
    return _db.collection('users').doc(_user!.uid).collection(name);
  }

  /// Fetches all user data (goals, tasks, rewards) from Firestore at once.
  /// This is typically called on user login to populate the local Hive cache.
  Future<void> pullAllData() async {
    if (_user == null) return;
    _isPerformingServerOperation = true;
    try {
      // Fetch all collections in parallel for efficiency.
      final results = await Future.wait([
        _collection('goals').get(),
        _collection('tasks').get(),
        _collection('rewards').get()
      ]);
      // Parse the results from each collection.
      final goals = (results[0] as QuerySnapshot)
          .docs
          .map((d) => Goal.fromJson(d.data() as Map<String, dynamic>))
          .toList();
      final tasks = (results[1] as QuerySnapshot)
          .docs
          .map((d) => Task.fromJson(d.data() as Map<String, dynamic>))
          .toList();
      final rewards = (results[2] as QuerySnapshot)
          .docs
          .map((d) => Reward.fromJson(d.data() as Map<String, dynamic>))
          .toList();
      // Replace data in the local Hive with remote
      await _hiveRepo.cacheAllData(
          goals: goals, tasks: tasks, rewards: rewards);
    } finally {
      _isPerformingServerOperation =
          false; // Signal that the operation is complete.
    }
  }

  /// --- Real-time Listener Management ---

  /// Initializes real-time listeners for BOTH Firebase collections and Local Hive boxes.
  /// This ensures that:
  /// 1. Remote changes in Firestore are pushed to Hive.
  /// 2. Local changes in Hive (via UI) are pushed to Firestore.
  void startRealtimeListeners() {
    if (_user == null) return;
    stopRealtimeListeners(); // Ensure old listeners are cleared.

    // 1. Listen to Remote Firebase Changes
    _listenToRemoteCollection<Goal>(
        'goals', Goal.fromJson, _hiveRepo.addGoal, _hiveRepo.deleteGoal);
    _listenToRemoteCollection<Task>(
        'tasks', Task.fromJson, _hiveRepo.addTask, _hiveRepo.deleteTask);
    _listenToRemoteCollection<Reward>('rewards', Reward.fromJson,
        _hiveRepo.addReward, _hiveRepo.deleteReward);

    // 2. Listen to Local Hive Changes
    _listenToLocalBox<Goal>(_hiveRepo.goalsBox, 'goals', syncGoal);
    _listenToLocalBox<Task>(_hiveRepo.tasksBox, 'tasks', syncTask);
    _listenToLocalBox<Reward>(_hiveRepo.rewardsBox, 'rewards', syncReward);
  }

  /// A generic method to listen for changes in a specific Firestore collection.
  void _listenToRemoteCollection<T>(
    String colName,
    T Function(Map<String, dynamic>) fromJson,
    Future<void> Function(T) cacheItem,
    Future<void> Function(String) deleteItem,
  ) {
    final sub = _collection(colName).snapshots().listen((snapshot) async {
      // IMPORTANT: We set this flag to TRUE so the Local Hive Listener knows
      // these changes came from the server and should NOT be pushed back.
      _isPerformingServerOperation = true;
      try {
        for (final change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null && change.type != DocumentChangeType.removed) {
            continue;
          }
          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              await cacheItem(fromJson(data!));
              break;
            case DocumentChangeType.removed:
              await deleteItem(change.doc.id);
              break;
          }
        }
      } catch (e) {
        // Log errors during snapshot processing.
      } finally {
        // Reset flag so user interactions can be synced again.
        _isPerformingServerOperation = false;
      }
    });
    _subscriptions.add(sub);
  }

  /// A generic method to listen for changes in a specific Hive Box.
  /// [box]: The Hive box to watch.
  /// [collectionName]: The Firestore collection to sync to.
  /// [uploadMethod]: The specific method to upload the object (e.g., syncGoal).
  void _listenToLocalBox<T>(
    Box<T>? box,
    String collectionName,
    Future<void> Function(T) uploadMethod,
  ) {
    if (box == null) return;

    final sub = box.watch().listen((BoxEvent event) {
      // CRITICAL: If the change happened because of _listenToRemoteCollection,
      // we stop here to prevent an infinite loop.
      if (_isPerformingServerOperation) return;

      if (event.deleted) {
        // If deleted locally, delete remotely.
        // Hive keys are usually Strings in this app, but safe cast ensures no crash.
        deleteDocument(event.key.toString(), collectionName);
      } else {
        // If added/updated locally, upload to Firestore.
        // event.value is the Object (Goal/Task/Reward).
        if (event.value != null && event.value is T) {
          uploadMethod(event.value as T);
        }
      }
    });
    _subscriptions.add(sub);
  }

  /// Cancels all active Firestore and Hive stream subscriptions.
  void stopRealtimeListeners() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// --- Public API for Syncing and State ---

  /// Public getter to allow other parts of the app to check if a server
  /// operation is in progress.
  bool get isPerformingServerOperation => _isPerformingServerOperation;

  /// Pushes a single `Goal` object to Firestore.
  Future<void> syncGoal(Goal g) async =>
      await _collection('goals').doc(g.id).set(g.toJson());

  /// Pushes a single `Task` object to Firestore.
  Future<void> syncTask(Task t) async =>
      await _collection('tasks').doc(t.id).set(t.toJson());

  /// Pushes a single `Reward` object to Firestore.
  Future<void> syncReward(Reward r) async =>
      await _collection('rewards').doc(r.id).set(r.toJson());

  /// Deletes a document from a specified collection in Firestore by its ID.
  Future<void> deleteDocument(String id, String col) async =>
      await _collection(col).doc(id).delete();
}
