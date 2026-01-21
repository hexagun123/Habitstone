// some set up (technically only two providers)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';
import 'goals.dart';

/// single repo instance so i don't have to have hive instances everywhere
final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  return HiveRepository();
});

/// initalizer provider with all nessecary information to be retrieved on startup
final appInitializerProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);

  // await the init of the repo
  await repo.init();

  // read the streak for once
  await ref.read(goalProvider.notifier).streakCheck();
});
