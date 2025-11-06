// lib/core/data/sync.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/app.dart';
import '../provider/auth.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';
import 'hive.dart';

class FirebaseSync {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HiveRepository _hiveRepo;

  // This is the correctly named flag.
  bool isSyncingFromServer = false;

  final List<StreamSubscription> _subscriptions = [];

  FirebaseSync(this._hiveRepo);

  User? get _user => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    if (_user == null) throw Exception("User not logged in.");
    return _db.collection('users').doc(_user!.uid).collection(name);
  }

  Future<void> pullAllData() async {
    if (_user == null) return;
    isSyncingFromServer = true;
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
      isSyncingFromServer = false;
    }
  }

  void startRealtimeListeners() {
    if (_user == null) return;
    stopRealtimeListeners();
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
      isSyncingFromServer = true;
      try {
        for (final change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null) continue;
          switch (change.type) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              await cacheItem(fromJson(data));
              break;
            case DocumentChangeType.removed:
              await deleteItem(change.doc.id);
              break;
          }
        }
      } finally {
        isSyncingFromServer = false;
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

  Future<void> syncGoal(Goal g) async =>
      await _collection('goals').doc(g.id).set(g.toJson());
  Future<void> syncTask(Task t) async =>
      await _collection('tasks').doc(t.id).set(t.toJson());
  Future<void> syncReward(Reward r) async =>
      await _collection('rewards').doc(r.id).set(r.toJson());
  Future<void> deleteDocument(String id, String col) async =>
      await _collection(col).doc(id).delete();
}

/// The provider that sets up the local listeners.
final syncControllerProvider = Provider.autoDispose<void>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  final syncService = ref.watch(firebaseSyncProvider);
  if (ref.watch(authStateProvider).value == null) return;

  hiveRepo.goalsBox?.watch().listen((event) {
    // MODIFIED: Checking the correct flag name.
    if (syncService.isSyncingFromServer) return;
    event.deleted
        ? syncService.deleteDocument(event.key, 'goals')
        : syncService.syncGoal(event.value);
  });
  hiveRepo.tasksBox?.watch().listen((event) {
    // MODIFIED: Checking the correct flag name.
    if (syncService.isSyncingFromServer) return;
    event.deleted
        ? syncService.deleteDocument(event.key, 'tasks')
        : syncService.syncTask(event.value);
  });
  hiveRepo.rewardsBox?.watch().listen((event) {
    // MODIFIED: Checking the correct flag name.
    if (syncService.isSyncingFromServer) return;
    event.deleted
        ? syncService.deleteDocument(event.key, 'rewards')
        : syncService.syncReward(event.value);
  });
});
