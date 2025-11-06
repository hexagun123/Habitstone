// core/provider/sync.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../provider/app.dart'; // Assumed path for hiveRepositoryProvider
import '../provider/auth.dart'; // Assumed path for auth providers

/// This provider's only job is to initialize the Hive listeners.
/// It doesn't return a value, but its creation triggers the setup.
final syncControllerProvider = Provider.autoDispose<void>((ref) {
  // Get the dependencies
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  final syncService = ref.watch(firebaseSyncProvider);
  
  // Only start listening if a user is logged in
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    print("SyncController: No user, listeners are off.");
    return;
  }

  print("SyncController: User is logged in, starting Hive listeners...");

  // --- GOAL LISTENER ---
  hiveRepo.goalsBox?.watch().listen((BoxEvent event) {
    // MODIFIED: Checking the correct flag name to prevent the sync loop.
    if (syncService.isSyncingFromServer) return;

    print("SyncController: Detected change in goalsBox!");
    if (event.deleted) {
      syncService.deleteDocument(event.key, 'goals');
    } else {
      syncService.syncGoal(event.value);
    }
  });

  // --- TASK LISTENER ---
  hiveRepo.tasksBox?.watch().listen((BoxEvent event) {
    // MODIFIED: Checking the correct flag name to prevent the sync loop.
    if (syncService.isSyncingFromServer) return;

    print("SyncController: Detected change in tasksBox!");
    if (event.deleted) {
      syncService.deleteDocument(event.key, 'tasks');
    } else {
      syncService.syncTask(event.value);
    }
  });

  // --- REWARD LISTENER ---
  hiveRepo.rewardsBox?.watch().listen((BoxEvent event) {
    // MODIFIED: Checking the correct flag name to prevent the sync loop.
    if (syncService.isSyncingFromServer) return;

    print("SyncController: Detected change in rewardsBox!");
    if (event.deleted) {
      syncService.deleteDocument(event.key, 'rewards');
    } else {
      syncService.syncReward(event.value);
    }
  });
});