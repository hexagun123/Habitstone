// This file sets up the data synchronization logic between the local Hive database
// and the remote Firebase database
// It defines Firebase as the single source of truth

import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../provider/app.dart';
import '../provider/auth.dart';
import '../data/sync.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';

/// a provider that manages the syncing process
/// listens to changes real time to update both database syncronously
final syncControllerProvider = Provider.autoDispose<void>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  final syncService = ref.watch(firebaseSyncProvider);

  /// Retrieve the current user from the authentication state.
  final user = ref.watch(authStateProvider).value;

  /// If there is no authenticated user, halt all synchronization activities.
  if (user == null) {
    syncService.stopRealtimeListeners(); // Stop listening for remote changes.
    return;
  }

  /// Ensure Firebase listeners are stopped when the user logs out or the app closes.
  ref.onDispose(() {
    syncService.stopRealtimeListeners();
  });

  /// Start listening for real-time updates from Firebase for the logged-in user
  /// if the above conditions are not met
  syncService.startRealtimeListeners();

  /// Fetches all data from Firebase when a user is authenticated.
  /// This initial pull ensures the local Hive database is up-to-date with the
  /// server's state before any local modifications are made.
  ref.watch(authStateProvider).whenData((user) {
    if (user != null) {
      // Check flag to prevent pulling data while another server operation is in progress.
      if (!syncService.isPerformingServerOperation) {
        syncService.pullAllData().catchError((e) {
          printToConsole(e); // in case of any error
        });
      }
    }
  });

  /// The goal listener:
  /// automatically triggers goal box syncing when state changes
  hiveRepo.goalsBox?.watch().listen((BoxEvent event) {
    // Prevents an infinite loop by ignoring local changes that were initiated by the server.
    // this is because pulling data from firebase also triggers syncing again
    // as such this will always trigger
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      // if deleted locally, delete from firebase
      syncService.deleteDocument(event.key, 'goals');
    } else {
      // if anything added, add it to firebase by syncing
      if (event.value != null) {
        syncService.syncGoal(event.value as Goal);
      }
    }
  });

  /// task listner:
  /// Listens for local changes in the Hive 'tasks' box and syncs them to Firebase.
  hiveRepo.tasksBox?.watch().listen((BoxEvent event) {

    /// to prevent infinite loop caused by serverside actions
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      // delete the document if locally deleted
      syncService.deleteDocument(event.key, 'tasks');
    } else {
      if (event.value != null) {
        // sync if anything is added
        syncService.syncTask(event.value as Task);
      }
    }
  });

  /// reward listener:
  /// Listens for local changes in the Hive 'rewards' box and syncs them to Firebase.
  hiveRepo.rewardsBox?.watch().listen((BoxEvent event) {
    /// prevents infinite loops
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'rewards');
      // delete if locally deleted
    } else {
      if (event.value != null) {
        syncService.syncReward(event.value as Reward);
        // sync if anything is added
      }
    }
  });
});
