/// This file defines core application-level providers using Riverpod.
/// It includes the provider for the Hive database repository and an
/// initialization provider to handle asynchronous startup tasks, ensuring
/// the app is in a valid state before the UI is displayed.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';
import 'goal.dart';

/// Provides a singleton instance of the [HiveRepository].
/// This is the central access point for all interactions with the local Hive database.
/// Riverpod manages its lifecycle, ensuring it is created only once.
final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  return HiveRepository();
});

/// An initializer provider to handle asynchronous setup logic before the app runs.
/// This `FutureProvider` ensures that critical services, like the database, are
/// ready. The UI can listen to this provider to show a loading indicator
/// while these tasks complete.
final appInitializerProvider = FutureProvider<void>((ref) async {
  // Obtain the repository instance from its provider.
  final repo = ref.read(hiveRepositoryProvider);

  // Initialize the repository, which involves opening all necessary Hive boxes.
  await repo.init();

  // Trigger the streak check logic after the database is ready.
  // `ref.read` is used here to execute the action once without listening for changes.
  await ref.read(goalProvider.notifier).streakCheck();

  // Other essential startup tasks could be awaited here.
});