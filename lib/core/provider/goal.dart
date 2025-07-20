// providers/goal_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/task.dart';
import '../data/hive.dart';
import '../model/goal.dart';
import '../data/util.dart';

// providers/goal_provider.dart
final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  throw UnimplementedError('Repository should be initialized in main');
});

final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier(ref.read(hiveRepositoryProvider), ref);
});

class GoalNotifier extends StateNotifier<List<Goal>> {
  final HiveRepository _repository;
  final Ref _ref; // Added Ref for accessing other providers

  GoalNotifier(this._repository, this._ref) : super(_repository.getGoals());

  Future<void> _refresh() async {
    state = [..._repository.getGoals()];
  }

  Future<void> createGoal(Goal goal) async {
    await _repository.addGoal(goal);
    await _refresh();
  }

  Future<void> updateGoal(Goal goal, Goal updatedGoal) async {
    final key = goal.key;
    if (key != null) {
      await _repository.updateGoal(key, updatedGoal);
      await _refresh();
    }
  }

  Future<void> deleteGoal(Goal goal) async {
    final key = goal.key;
    if (key != null) {
      // Remove goal from all tasks
      final tasks = _ref.read(taskProvider);
      final taskNotifier = _ref.read(taskProvider.notifier);
      for (final task in tasks) {
        if (task.goalIds.contains(key)) {
          task.removeGoal(key);
          if (task.key != null) {
            await taskNotifier.updateTask(task);
          }
        }
      }

      await _repository.deleteGoal(key);
      await _refresh();
    }
  }

  Future<void> markGoalAsUpdated(Goal goal) async {
    final now = DateTime.now().toUtc();
    final today = DateUtil.toMidnight(now);
    final lastUpdate = DateUtil.toMidnight(goal.lastUpdate);
    final yesterday = today.subtract(const Duration(days: 1));

    Goal updatedGoal = goal.copyWith(
      updated: true,
      lastUpdate: now,
    );
    if (lastUpdate.isBefore(today)) {
      if (goal.updated && lastUpdate == yesterday) {
        updatedGoal = updatedGoal.copyWith(streak: goal.streak + 1);
      } else {
        updatedGoal = updatedGoal.copyWith(streak: 1);
      }
    }

    await updateGoal(goal, updatedGoal);
  }

  Future<void> checkStreaksOnStartup() async {
    final now = DateTime.now().toUtc();
    final today = DateUtil.toMidnight(now);

    for (final goal in state) {
      final lastUpdate = DateUtil.toMidnight(goal.lastUpdate);
      Goal updatedGoal;

      if (lastUpdate.isBefore(today)) {
        updatedGoal = goal.copyWith(updated: false);
      } else {
        updatedGoal = goal.copyWith(streak: 0, updated: false);
      }

      if (updatedGoal != goal) {
        await updateGoal(goal, updatedGoal);
      }
    }
  }
}
