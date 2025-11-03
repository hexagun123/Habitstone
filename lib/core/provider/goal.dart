import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task.dart';
import '../model/goal.dart';
import '../data/util.dart';
import 'app.dart';
import '../data/hive.dart';

final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier(ref.watch(hiveRepositoryProvider), ref);
});

class GoalNotifier extends StateNotifier<List<Goal>> {
  final HiveRepository _repository;
  final Ref _ref;

  GoalNotifier(this._repository, this._ref) : super(_repository.getGoals());

  Future<void> _refresh() async => state = [..._repository.getGoals()];

  Future<void> createGoal(Goal goal) async {
    await _repository.addGoal(goal);
    await _refresh();
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    await _repository.updateGoal(updatedGoal.id, updatedGoal);
    await _refresh();
  }

  Future<void> deleteGoal(Goal goal) async {
    final String goalIdToDelete = goal.id;
    final tasks = _ref.read(taskProvider);
    final taskNotifier = _ref.read(taskProvider.notifier);

    for (final task in tasks) {
      if (task.goalIds.contains(goalIdToDelete)) {
        task.removeGoal(goalIdToDelete);
        await taskNotifier.updateTask(task);
      }
    }
    await _repository.deleteGoal(goalIdToDelete);
    await _refresh();
  }

  Future<void> addStreak(Goal goal) async {
    if (!goal.updated) {
      Goal updatedGoal = goal.copyWith(
        streak: goal.streak + 1,
        updated: true,
        lastUpdate: DateUtil.now(),
      );
      await updateGoal(updatedGoal);
    }
  }

  Future<void> streakCheck() async {
    final now = DateUtil.now();
    for (final goal in state) {
      Goal? updatedGoal;
      final lastUpdate = goal.lastUpdate;
      // Use DateUtils.isSameDay for robust date comparison
      if (DateUtils.isSameDay(lastUpdate, now) == false) {
        if (!goal.updated) {
          // Streak is broken
          updatedGoal = goal.copyWith(
            streak: 0,
            updated: false,
            lastUpdate: now,
          );
        } else {
          // Just reset the 'updated' flag for the new day
          updatedGoal = goal.copyWith(
            updated: false,
            lastUpdate: now,
          );
        }
      }
      if (updatedGoal != null) {
        await updateGoal(updatedGoal);
      }
    }
  }
}