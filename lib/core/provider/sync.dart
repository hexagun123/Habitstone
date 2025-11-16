/// This file sets up the data synchronization logic between the local Hive database
/// and the remote Firebase Firestore database using Riverpod providers. It ensures
/// that local data changes are pushed to the cloud and remote changes are pulled
/// down, maintaining data consistency across the application.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../provider/app.dart';
import '../provider/auth.dart';
import '../data/sync.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';

/// Provides an instance of the [FirebaseSync] service.
/// This service encapsulates the core logic for interacting with Firebase Firestore,
/// such as pushing updates, pulling data, and deleting documents.
final firebaseSyncProvider = Provider<FirebaseSync>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  return FirebaseSync(hiveRepo);
});

/// This provider acts as the main controller for the synchronization process.
/// It initializes and manages listeners for both local (Hive) and remote (Firebase)
/// data changes. The `autoDispose` modifier ensures that all listeners are cleaned
// up automatically when the provider is no longer in use, preventing memory leaks.
final syncControllerProvider = Provider.autoDispose<void>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  final syncService = ref.watch(firebaseSyncProvider);

  // Retrieve the current user from the authentication state.
  final user = ref.watch(authStateProvider).value;

  // If there is no authenticated user, halt all synchronization activities.
  if (user == null) {
    syncService.stopRealtimeListeners(); // Stop listening for remote changes.
    return;
  }

  // Ensure Firebase listeners are stopped when the user logs out or the app closes.
  ref.onDispose(() {
    syncService.stopRealtimeListeners();
  });
  // Start listening for real-time updates from Firebase for the logged-in user.
  syncService.startRealtimeListeners();

  /// Fetches all data from Firebase when a user is authenticated.
  /// This initial pull ensures the local Hive database is up-to-date with the
  /// server's state before any local modifications are made.
  ref.watch(authStateProvider).whenData((user) {
    if (user != null) {
      // Check flag to prevent pulling data while another server operation is in progress.
      if (!syncService.isPerformingServerOperation) {
        syncService.pullAllData().catchError((e) {
          // Log any errors during the initial data fetch.
        });
      }
    }
  });

  /// --- GOAL LISTENER ---
  /// Listens for local changes in the Hive 'goals' box.
  /// When a change is detected, it triggers the corresponding synchronization
  /// action (update, add, or delete) to Firebase.
  hiveRepo.goalsBox?.watch().listen((BoxEvent event) {
    // Prevents an infinite loop by ignoring local changes that were initiated by the server.
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      // If a goal is deleted locally, delete it from Firebase.
      syncService.deleteDocument(event.key, 'goals');
    } else {
      // If a goal is added or updated, sync its data to Firebase.
      if (event.value != null) {
        syncService.syncGoal(event.value as Goal);
      }
    }
  });

  /// --- TASK LISTENER ---
  /// Listens for local changes in the Hive 'tasks' box and syncs them to Firebase.
  hiveRepo.tasksBox?.watch().listen((BoxEvent event) {
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'tasks');
    } else {
      if (event.value != null) {
        syncService.syncTask(event.value as Task);
      }
    }
  });

  /// --- REWARD LISTENER ---
  /// Listens for local changes in the Hive 'rewards' box and syncs them to Firebase.
  hiveRepo.rewardsBox?.watch().listen((BoxEvent event) {
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'rewards');
    } else {
      if (event.value != null) {
        syncService.syncReward(event.value as Reward);
      }
    }
  });
});
