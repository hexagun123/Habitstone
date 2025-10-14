// core/provider/goal.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/task.dart';
import '../data/hive.dart';
import '../model/goal.dart';
import '../data/util.dart';
import '../provider/hive.dart';

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

  Future<void> addStreak(Goal goal) async {
    if (!goal.updated) {
      Goal updatedGoal = goal.copyWith(
        streak: goal.streak + 1,
        updated: true,
        lastUpdate: DateUtil.now(),
      );

      await updateGoal(goal, updatedGoal);
    }
  }

  Future<void> streakCheck() async {
    final now = DateUtil.now();

    for (final goal in state) {
      final lastUpdate = goal.lastUpdate;
      Goal updatedGoal;

      if (!lastUpdate.isAtSameMomentAs(now)) {
        if (!goal.updated) {
          updatedGoal = goal.copyWith(
            lastUpdate: now,
            updated: false,
            streak: 0, // you failed the streak ... time to get haunted
          );
        } else {
          updatedGoal = goal.copyWith(
            lastUpdate: now,
            updated: false,
          );
        }
      } else {
        updatedGoal = goal; // dont spam the button please
      }

      if (updatedGoal != goal) {
        await updateGoal(goal, updatedGoal);
        print(goal.toString());
      }
    }
  }
}
