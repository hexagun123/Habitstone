// lib/providers/goal.dart
// This file defines the state management logic for goals using Riverpod.
// It includes the `GoalNotifier` which handles business logic such as creating,
// updating, deleting goals, and managing their daily streaks.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task.dart';
import '../model/goal.dart';
import '../data/util.dart';
import 'app.dart';
import '../data/hive.dart';

/// Provider that exposes the [GoalNotifier] and its state (`List<Goal>`).
/// This allows the UI to interact with the goals and listen for changes.
final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier(ref.watch(hiveRepositoryProvider), ref);
});

/// Manages the state of the goal list (`List<Goal>`).
///
/// This notifier is the central point for all goal-related operations.
/// It interacts with the persistence layer ([HiveRepository]) to store and
/// retrieve goal data and coordinates with the [TaskNotifier] when goals
/// are deleted.
class GoalNotifier extends StateNotifier<List<Goal>> {
  final HiveRepository _repository;
  final Ref _ref;

  /// Initializes the notifier by loading the initial list of goals from the repository.
  GoalNotifier(this._repository, this._ref) : super(_repository.getGoals());

  /// Refreshes the state by fetching the latest goal list from the repository.
  /// This ensures the in-memory state is synchronized with the persistent storage.
  Future<void> _refresh() async => state = [..._repository.getGoals()];

  /// Persists a new goal and updates the state.
  Future<void> createGoal(Goal goal) async {
    await _repository.addGoal(goal);
    await _refresh();
  }

  /// Updates an existing goal in the repository and refreshes the state.
  Future<void> updateGoal(Goal updatedGoal) async {
    await _repository.updateGoal(updatedGoal.id, updatedGoal);
    await _refresh();
  }

  /// Deletes a goal and cleans up its references in any associated tasks.
  ///
  /// This method first iterates through all tasks to remove the ID of the
  /// deleted goal from their `goalIds` list. After cleaning up the references,
  /// it deletes the goal from the repository and refreshes the state.
  Future<void> deleteGoal(Goal goal) async {
    final String goalIdToDelete = goal.id;
    final tasks = _ref.read(taskProvider);
    final taskNotifier = _ref.read(taskProvider.notifier);

    // Remove the goal's ID from any task that references it.
    for (final task in tasks) {
      if (task.goalIds.contains(goalIdToDelete)) {
        task.removeGoal(goalIdToDelete);
        await taskNotifier.updateTask(task);
      }
    }
    // Delete the goal itself from storage.
    await _repository.deleteGoal(goalIdToDelete);
    await _refresh();
  }

  /// Increments the streak count for a given goal.
  ///
  /// This action is only performed if the goal has not already been updated today,
  /// preventing multiple streak increments on the same day. It also marks the
  /// goal as updated for the current day.
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

  /// Performs a daily check on all goals to maintain streak integrity.
  ///
  /// This method should be called once daily (e.g., on app startup). It iterates
  /// through each goal and checks if its `lastUpdate` was before the current day.
  /// - If a goal was `updated` yesterday, its `updated` flag is reset for the new day.
  /// - If a goal was *not* `updated` yesterday, its streak is broken and reset to 0.
  Future<void> streakCheck() async {
    final now = DateUtil.now();
    await _refresh();
    for (final goal in state) {
      Goal? updatedGoal;
      final lastUpdate = goal.lastUpdate;

      // Use DateUtils.isSameDay for a robust comparison that ignores time of day.
      if (DateUtils.isSameDay(lastUpdate, now) == false) {
        if (!goal.updated) {
          // Streak is broken because a day was missed.
          updatedGoal = goal.copyWith(
            streak: 0,
            updated: false,
            lastUpdate: now,
          );
        } else {
          // Streak continues; just reset the 'updated' flag for the new day.
          updatedGoal = goal.copyWith(
            updated: false,
            lastUpdate: now,
          );
        }
      }

      // If any changes were determined, update the goal in the repository.
      if (updatedGoal != null) {
        await updateGoal(updatedGoal);
      }
    }
  }
}
