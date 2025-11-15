// core/provider/sync.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart'; // REQUIRED for BoxEvent
import '../provider/app.dart'; // For hiveRepositoryProvider
import '../provider/auth.dart'; // For authStateProvider
import '../data/sync.dart'; // For FirebaseSync class
import '../model/goal.dart'; // For Goal type casting
import '../model/task.dart'; // For Task type casting
import '../model/reward.dart'; // For Reward type casting

// Provider for the FirebaseSync service itself
final firebaseSyncProvider = Provider<FirebaseSync>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  return FirebaseSync(hiveRepo);
});

/// This provider initializes and manages the local Hive listeners
/// that push changes to Firebase, respecting the sync state.
final syncControllerProvider = Provider.autoDispose<void>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  final syncService = ref.watch(firebaseSyncProvider);

  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    // If user logs out or is null, stop all sync operations
    syncService.stopRealtimeListeners();
    // Potentially clear local data if it's user-specific and not for offline-first multi-user
    // await hiveRepo.clearAllBoxes(); // Use with caution, depending on app logic
    return;
  }

  // When a user is logged in, start Firebase real-time listeners.
  // Ensure they are stopped when this provider is disposed (e.g., user logs out).
  ref.onDispose(() {
    syncService.stopRealtimeListeners();
  });
  syncService.startRealtimeListeners();

  // It's crucial to perform a full data pull from Firebase to Hive
  // when the user signs in or the app starts with an authenticated user.
  // This ensures the local cache is up-to-date before any local edits happen.
  // This should ideally happen *once* after successful authentication.
  // You might want to move this into an app initialization flow or auth state change listener.
  // For now, doing it here will ensure it runs when the provider is initialized for an authenticated user.
  ref.watch(authStateProvider).whenData((user) {
    if (user != null) {
      // Only pull data if user is authenticated and not already syncing from server
      if (!syncService.isPerformingServerOperation) {
        syncService.pullAllData().catchError((e) {
          print("Error pulling initial data: $e");
          // Handle error, e.g., show a snackbar to the user
        });
      }
    }
  });

  // --- GOAL LISTENER ---
  hiveRepo.goalsBox?.watch().listen((BoxEvent event) {
    // If FirebaseSync is currently processing a server-initiated change,
    // we should ignore this local Hive change to prevent a sync loop.
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'goals');
    } else {
      if (event.value != null) {
        syncService.syncGoal(event.value as Goal);
      } else {
        print(
            "Warning: Hive goal event with null value for key ${event.key}, type ${event.deleted ? 'deleted' : 'modified/added'}");
      }
    }
  });

  // --- TASK LISTENER ---
  hiveRepo.tasksBox?.watch().listen((BoxEvent event) {
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'tasks');
    } else {
      if (event.value != null) {
        syncService.syncTask(event.value as Task);
      } else {
        print(
            "Warning: Hive task event with null value for key ${event.key}, type ${event.deleted ? 'deleted' : 'modified/added'}");
      }
    }
  });

  // --- REWARD LISTENER ---
  hiveRepo.rewardsBox?.watch().listen((BoxEvent event) {
    if (syncService.isPerformingServerOperation) {
      return;
    }

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'rewards');
    } else {
      if (event.value != null) {
        syncService.syncReward(event.value as Reward);
      } else {
        print(
            "Warning: Hive reward event with null value for key ${event.key}, type ${event.deleted ? 'deleted' : 'modified/added'}");
      }
    }
  });
});
