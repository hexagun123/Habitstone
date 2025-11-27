// core/data/sync.dart


import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
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

  // Holds all active stream subscriptions to be cancelled later.
  final List<StreamSubscription> _subscriptions = [];

  // Names of the Hive boxes (Must match HiveRepository)
  static const String _goalsBoxName = 'goals_box';
  static const String _tasksBoxName = 'tasks_box';
  static const String _rewardsBoxName = 'rewards_box';

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

    // CRITICAL: Wait for Hive to be ready so we don't crash
    await _hiveRepo.waitForInitialization;

    print("FirebaseSync: Pulling all data from Firestore...");
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

      print(
          "FirebaseSync: Data pull complete. Cached ${goals.length} goals, ${tasks.length} tasks, ${rewards.length} rewards.");
    } catch (e) {
      print("FirebaseSync Error during pullAllData: $e");
    } finally {
      _isPerformingServerOperation =
          false; // Signal that the operation is complete.
    }
  }

  /// --- Real-time Listener Management ---

  /// Initializes real-time listeners for all user data collections.
  /// Any changes in Firestore will be automatically pushed to the local Hive cache.
  /// Also sets up listeners on Hive boxes to push local changes to Firestore.
  Future<void> startRealtimeListeners() async {
    if (_user == null) return;

    // 1. Stop existing listeners to avoid duplicates
    stopRealtimeListeners();

    print("FirebaseSync: Waiting for HiveRepository to initialize...");
    // 2. Wait for Hive to be fully ready
    await _hiveRepo.waitForInitialization;
    print("FirebaseSync: Hive is ready. Attaching real-time listeners...");

    // 3. Listen to Remote Firebase Changes
    _listenToRemoteCollection<Goal>(
        'goals', Goal.fromJson, _hiveRepo.addGoal, _hiveRepo.deleteGoal);
    _listenToRemoteCollection<Task>(
        'tasks', Task.fromJson, _hiveRepo.addTask, _hiveRepo.deleteTask);
    _listenToRemoteCollection<Reward>('rewards', Reward.fromJson,
        _hiveRepo.addReward, _hiveRepo.deleteReward);

    // 4. Listen to Local Hive Changes (using safe box lookup)
    _listenToLocalBox<Goal>(_goalsBoxName, 'goals', syncGoal);
    _listenToLocalBox<Task>(_tasksBoxName, 'tasks', syncTask);
    _listenToLocalBox<Reward>(_rewardsBoxName, 'rewards', syncReward);
  }

  /// A generic method to listen for changes in a specific Firestore collection.
  void _listenToRemoteCollection<T>(
    String colName,
    T Function(Map<String, dynamic>) fromJson,
    Future<void> Function(T) cacheItem,
    Future<void> Function(String) deleteItem,
  ) {
    final sub = _collection(colName).snapshots().listen((snapshot) async {
      _isPerformingServerOperation =
          true; // Set flag for this batch of changes.
      try {
        for (final change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null && change.type != DocumentChangeType.removed) {
            continue; // Skip invalid data for add/modified events.
          }

          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              // print("FirebaseSync (Remote -> Local): $colName item ${change.type.name.toUpperCase()} - ID: ${change.doc.id}");
              await cacheItem(fromJson(data!));
              break;
            case DocumentChangeType.removed:
              await deleteItem(change.doc.id);
              break;
          }
        }
      } catch (e) {
        print("FirebaseSync Error processing remote snapshot for $colName: $e");
      } finally {
        _isPerformingServerOperation =
            false; // Reset flag once all changes are processed.
      }
    });
    _subscriptions.add(sub); // Store the subscription to be cancelled later.
  }

  /// A generic method to listen for changes in a specific Hive Box.
  ///
  /// It looks up the box using [boxName] via `Hive.box<T>()` to ensure it uses
  /// the active instance.
  void _listenToLocalBox<T>(
    String boxName,
    String collectionName,
    Future<void> Function(T) uploadMethod,
  ) {
    if (!Hive.isBoxOpen(boxName)) {
      print(
          "FirebaseSync CRITICAL: Box '$boxName' is NOT open despite waiting for init. Listener not attached.");
      return;
    }

    final box = Hive.box<T>(boxName);
    print(
        "FirebaseSync: Attached listener to Local Box '$boxName' (${box.length} items currently).");

    final sub = box.watch().listen((BoxEvent event) async {
      // PREVENT LOOP: If this change came from Firebase, do nothing.
      if (_isPerformingServerOperation) {
        // print("FirebaseSync: Skipping local event for $collectionName (Server Operation in progress)");
        return;
      }

      try {
        if (event.deleted) {
          // If deleted locally, delete remotely.
          print(
              "FirebaseSync (Local -> Remote): Deleting $collectionName item. Key: ${event.key}");
          await deleteDocument(event.key.toString(), collectionName);
        } else {
          // If added/updated locally, upload to Firestore.
          final dynamic value = event.value;
          if (value != null) {
            print(
                "FirebaseSync (Local -> Remote): Detected change in $collectionName. Uploading...");

            // Safe cast to T
            if (value is T) {
              await uploadMethod(value);
              print("FirebaseSync: Upload success for $collectionName.");
            } else {
              print(
                  "FirebaseSync Error: Value in box was not of type $T. It was ${value.runtimeType}");
            }
          }
        }
      } catch (e) {
        print(
            "FirebaseSync Error syncing local change for $collectionName: $e");
      }
    });
    _subscriptions.add(sub);
  }

  /// Cancels all active Firestore stream subscriptions.
  /// This is crucial to call on user logout to prevent memory leaks and errors.
  void stopRealtimeListeners() {
    if (_subscriptions.isNotEmpty) {
      print(
          "FirebaseSync: Stopping ${_subscriptions.length} active listeners.");
      for (final sub in _subscriptions) {
        sub.cancel();
      }
      _subscriptions.clear();
    }
  }

  /// --- Public API for Syncing and State ---

  /// Public getter to allow other parts of the app to check if a server
  /// operation is in progress, useful for preventing sync loops.
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
