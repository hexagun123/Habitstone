// core/provider/sync.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../provider/app.dart';
import '../provider/auth.dart'; 

final syncControllerProvider = Provider.autoDispose<void>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  final syncService = ref.watch(firebaseSyncProvider);
  
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return;
  }


  hiveRepo.goalsBox?.watch().listen((BoxEvent event) {
    if (syncService.isSyncingFromServer) return;

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'goals');
    } else {
      syncService.syncGoal(event.value);
    }
  });

  // --- TASK LISTENER ---
  hiveRepo.tasksBox?.watch().listen((BoxEvent event) {
    if (syncService.isSyncingFromServer) return;

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'tasks');
    } else {
      syncService.syncTask(event.value);
    }
  });

  // --- REWARD LISTENER ---
  hiveRepo.rewardsBox?.watch().listen((BoxEvent event) {
    if (syncService.isSyncingFromServer) return;

    if (event.deleted) {
      syncService.deleteDocument(event.key, 'rewards');
    } else {
      syncService.syncReward(event.value);
    }
  });
});