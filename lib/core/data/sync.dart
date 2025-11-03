import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';
import 'hive.dart';

class FirebaseSync {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HiveRepository _hiveRepo;

  FirebaseSync(this._hiveRepo);

  User? get _user => _auth.currentUser;

  // Helper to get a user-specific collection reference
  CollectionReference<Map<String, dynamic>> _collection(String name) {
    if (_user == null)
      throw Exception("User is not logged in for sync operation.");
    return _db.collection('users').doc(_user!.uid).collection(name);
  }

  /// PULL: Fetches all data from Firestore and overwrites the local Hive database.
  /// This is typically called right after a user logs in.
  Future<void> pullAllData() async {
    if (_user == null) {
      print("Sync Service: Cannot pull data, no user logged in.");
      return;
    }
    print("Sync Service: Starting data pull from Firebase...");
    try {
      // Fetch all collections in parallel for better performance
      final goalsFuture = _collection('goals').get();
      final tasksFuture = _collection('tasks').get();
      final rewardsFuture = _collection('rewards').get();

      final results =
          await Future.wait([goalsFuture, tasksFuture, rewardsFuture]);

      // Deserialize Firestore documents into our Dart models
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

      // Use the new caching methods in HiveRepository to store the fresh data
      await _hiveRepo.cacheAllData(
          goals: goals, tasks: tasks, rewards: rewards);

      print(
          "Sync Service: Data pull successful. Hive is now in sync with Firebase.");
    } catch (e) {
      print("Sync Service: 🛑 Firebase data pull failed: $e");
      // Don't throw an error, just log it. The app can continue in offline mode.
    }
  }

  /// Pushes a single Goal document to Firestore.
  Future<void> syncGoal(Goal goal) async {
    if (_user == null) return;
    try {
      await _collection('goals').doc(goal.id).set(goal.toJson());
    } catch (e) {
      print("Failed to sync goal ${goal.id}: $e");
    }
  }

  /// Pushes a single Task document to Firestore.
  Future<void> syncTask(Task task) async {
    if (_user == null) return;
    try {
      await _collection('tasks').doc(task.id).set(task.toJson());
    } catch (e) {
      print("Failed to sync task ${task.id}: $e");
    }
  }

  /// Pushes a single Reward document to Firestore.
  Future<void> syncReward(Reward reward) async {
    if (_user == null) return;
    try {
      await _collection('rewards').doc(reward.id).set(reward.toJson());
    } catch (e) {
      print("Failed to sync reward ${reward.id}: $e");
    }
  }

  /// Deletes a document from a specified collection in Firestore.
  Future<void> deleteDocument(String id, String collectionName) async {
    if (_user == null) return;
    try {
      await _collection(collectionName).doc(id).delete();
    } catch (e) {
      print("Failed to delete document $id from $collectionName: $e");
    }
  }

  /// PUSH: Takes all local data from Hive and overwrites Firestore.
  /// This can be called periodically or before logging out.
  Future<void> pushAllData() async {
    if (_user == null) {
      print("Sync Service: Cannot push data, no user logged in.");
      return;
    }
    print("Sync Service: Starting data push to Firebase...");
    try {
      // Use a WriteBatch for an efficient, atomic "all-or-nothing" write.
      final batch = _db.batch();

      // Get all local data from Hive
      final goals = _hiveRepo.getGoals();
      final tasks = _hiveRepo.getTasks();
      final rewards = _hiveRepo.getRewards();

      // Stage the writes for goals
      for (final goal in goals) {
        final docRef = _collection('goals').doc(goal.id);
        batch.set(docRef, goal.toJson());
      }

      // Stage the writes for tasks
      for (final task in tasks) {
        final docRef = _collection('tasks').doc(task.id);
        batch.set(docRef, task.toJson());
      }

      // Stage the writes for rewards
      for (final reward in rewards) {
        final docRef = _collection('rewards').doc(reward.id);
        batch.set(docRef, reward.toJson());
      }

      // Commit all writes to Firebase in a single operation
      await batch.commit();

      print(
          "Sync Service: Data push successful. Firebase is now in sync with Hive.");
    } catch (e) {
      print("Sync Service: 🛑 Firebase data push failed: $e");
    }
  }
}
