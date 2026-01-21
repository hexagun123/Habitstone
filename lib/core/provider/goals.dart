// lib/providers/goal.dart
// all the goal management functions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task.dart';
import '../model/goal.dart';
import '../data/util.dart';
import 'app.dart';
import '../data/hive.dart';

// watch the goal states
// we have it here to be retrieved from other files, its not used in this file
final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier(ref.watch(hiveRepositoryProvider), ref);
});

/// Manages the states of the goal list
class GoalNotifier extends StateNotifier<List<Goal>> {
  final HiveRepository _repository;
  final Ref _ref; // deprecated, but we can still use it for now

  /// Initializes the notifier by loading from the hive repo (which should be the one on app.dart)
  GoalNotifier(this._repository, this._ref) : super(_repository.getGoals());

  /// refreshing the states by fetching the newest goals from the repo
  Future<void> _refresh() async => state = [..._repository.getGoals()];

  /// create a new goal and updates the state.
  Future<void> createGoal(Goal goal) async {
    await _repository.addGoal(goal);
    await _refresh();
  }

  /// update an existing goal in the repository and refreshes the state.
  Future<void> updateGoal(Goal updatedGoal) async {
    await _repository.updateGoal(updatedGoal.id, updatedGoal);
    await _refresh();
  }

  /// To delete a goal, we iterates through all tasks to remove the ID of the
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

  /// Incrementing streaks is only performed if the goal has not already been updated today,
  /// preventing multiple streak increments on the same day.
  /// we basically just do copyWith and change some values

  Future<void> addStreak(Goal goal) async {
    if (!goal.updated) {
      Goal updatedGoal = goal.copyWith(
        streak: goal.streak + 1,
        updated: true,
        lastUpdate: Util.now(), // returns utc time, see util.dart
      );
      await updateGoal(updatedGoal);
    }
  }

  /// Checking the streak
  /// This method should be called on startup.
  /// It iterates through each goal and checks if its `lastUpdate` was before the current day.
  /// - If a goal was updated yesterday, its `updated` flag is reset for the new day.
  /// - If a goal was not updated yesterday, its streak is broken and reset to 0.

  Future<void> streakCheck() async {
    final now = Util.now();

    await _refresh();

    // loop the goals
    for (final goal in state) {
      Goal? updatedGoal;
      final lastUpdate = goal.lastUpdate;

  
      // if on the same day, do nothing
      // only check if we are on different days
      // using the flutter dateutils package for checks
      if (DateUtils.isSameDay(lastUpdate, now) == false) {

        // checking first if more than one day has passed
        if (DateUtils.isSameDay(lastUpdate, now.subtract(Duration(days: 1)))==false) {
            updatedGoal = goal.copyWith(
            streak: 0,
            updated: false,
            lastUpdate: now,
          ); 
            }
        
        // else if the goal is not updated
        if (!goal.updated) {
          // Streak is broken because a day was missed.
          updatedGoal = goal.copyWith(
            streak: 0,
            updated: false,
            lastUpdate: now,
          );
        } else {
        // the user has opened the app on a new day, but didn't do anything yet
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
