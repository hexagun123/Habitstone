// core/provider/app_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';
import 'goal.dart'; // Assuming your goalProvider is here

// 1. Provider for your HiveRepository
// This replaces your global variable. Now Riverpod manages its lifecycle.
final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  // This provider will only be created once and the same instance will be
  // returned every time, effectively making it a singleton.
  return HiveRepository();
});

// 2. An Initializer Provider for your startup logic
// This is the correct way to handle async actions like opening boxes
// and running checks before the app is ready.
final appInitializerProvider = FutureProvider<void>((ref) async {
  // Get the repository instance from its provider.
  final repo = ref.read(hiveRepositoryProvider);

  // Initialize the repository (open boxes).
  await repo.init();

  // Now, run your streak check logic using its own provider.
  // We use `ref.read` because we just want to execute the action.
  await ref.read(goalProvider.notifier).streakCheck();

  // If there were other startup tasks, you would await them here.
});