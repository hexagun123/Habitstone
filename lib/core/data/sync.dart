// lib/core/data/sync.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // REMOVE THIS IF NOT USED BY FirebaseSync CLASS ITSELF
// import '../provider/app.dart'; // REMOVE THIS IF NOT USED BY FirebaseSync CLASS ITSELF
// import '../provider/auth.dart'; // REMOVE THIS IF NOT USED BY FirebaseSync CLASS ITSELF
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';
import 'hive.dart';

// You will likely have a provider that provides this FirebaseSync instance,
// e.g., final firebaseSyncProvider = Provider((ref) => FirebaseSync(ref.watch(hiveRepositoryProvider)));

class FirebaseSync {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HiveRepository _hiveRepo;

  bool _isPerformingServerOperation = false; // Renamed for clarity on purpose

  final List<StreamSubscription> _subscriptions = [];

  FirebaseSync(this._hiveRepo);

  User? get _user => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    if (_user == null) throw Exception("User not logged in.");
    return _db.collection('users').doc(_user!.uid).collection(name);
  }

  Future<void> pullAllData() async {
    if (_user == null) return;
    _isPerformingServerOperation = true;
    try {
      final results = await Future.wait([
        _collection('goals').get(),
        _collection('tasks').get(),
        _collection('rewards').get()
      ]);
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
      await _hiveRepo.cacheAllData(
          goals: goals, tasks: tasks, rewards: rewards);
    } finally {
      _isPerformingServerOperation = false;
    }
  }

  void startRealtimeListeners() {
    if (_user == null) return;
    stopRealtimeListeners(); // Ensure old listeners are cleared
    _listenToCollection<Goal>(
        'goals', Goal.fromJson, _hiveRepo.addGoal, _hiveRepo.deleteGoal);
    _listenToCollection<Task>(
        'tasks', Task.fromJson, _hiveRepo.addTask, _hiveRepo.deleteTask);
    _listenToCollection<Reward>('rewards', Reward.fromJson, _hiveRepo.addReward,
        _hiveRepo.deleteReward);
  }

  void _listenToCollection<T>(
    String colName,
    T Function(Map<String, dynamic>) fromJson,
    Future<void> Function(T) cacheItem,
    Future<void> Function(String) deleteItem,
  ) {
    final sub = _collection(colName).snapshots().listen((snapshot) async {
      _isPerformingServerOperation = true; // Set flag for this snapshot's processing
      try {
        for (final change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null && change.type != DocumentChangeType.removed) {
             print('Warning: Document data is null for change type ${change.type} on document ${change.doc.id}');
             continue;
          }
          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              await cacheItem(fromJson(data!)); // Data is not null here
              break;
            case DocumentChangeType.removed:
              await deleteItem(change.doc.id);
              break;
          }
        }
      } catch (e) {
        print("Error processing Firestore snapshot for $colName: $e");
      } finally {
        _isPerformingServerOperation = false; // Reset flag
      }
    });
    _subscriptions.add(sub);
  }

  void stopRealtimeListeners() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  // Exposed getter
  bool get isPerformingServerOperation => _isPerformingServerOperation;

  Future<void> syncGoal(Goal g) async =>
      await _collection('goals').doc(g.id).set(g.toJson());
  Future<void> syncTask(Task t) async =>
      await _collection('tasks').doc(t.id).set(t.toJson());
  Future<void> syncReward(Reward r) async =>
      await _collection('rewards').doc(r.id).set(r.toJson());
  Future<void> deleteDocument(String id, String col) async =>
      await _collection(col).doc(id).delete();
}
// Delete the old syncControllerProvider definition from here.