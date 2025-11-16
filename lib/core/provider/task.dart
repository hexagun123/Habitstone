// lib/providers/task.dart
// This file defines the state management for tasks using Riverpod.
// It includes the main `TaskNotifier` which handles all business logic related to tasks,
// such as CRUD operations, completion logic, and a weighted random selection algorithm.
// It also defines several derived providers for UI consumption.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../model/task.dart';
import 'goal.dart';
import '../data/util.dart';
import 'app.dart';
import 'setting.dart';
import '../data/hive.dart';
import 'package:collection/collection.dart';

/// Provider that exposes the [TaskNotifier] to the application.
/// This allows UI widgets to listen to the list of tasks and interact with the notifier.
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.watch(hiveRepositoryProvider), ref);
});

/// Manages the state of the task list (`List<Task>`).
///
/// This notifier is responsible for all operations related to tasks, including
/// creating, updating, deleting, and processing task completions. It interfaces

/// with a [HiveRepository] for data persistence.
class TaskNotifier extends StateNotifier<List<Task>> {
  final HiveRepository _repository;
  final Ref _ref;

  /// Initializes the notifier by loading the initial list of tasks from the repository.
  TaskNotifier(this._repository, this._ref) : super(_repository.getTasks());

  /// Refreshes the state by fetching the latest task list from the repository.
  Future<void> _refresh() async => state = [..._repository.getTasks()];

  /// Persists a new task and updates the state.
  Future<void> createTask(Task task) async {
    await _repository.addTask(task);
    await _refresh();
  }

  /// Updates an existing task in the repository and refreshes the state.
  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task.id, task);
    await _refresh();
  }

  /// Deletes a task from the repository and refreshes the state.
  Future<void> deleteTask(Task task) async {
    await _repository.deleteTask(task.id);
    await _refresh();
  }

  /// Returns a list of tasks that are currently not displayed to the user.
  List<Task> get hiddenTasks => state.where((task) => !task.display).toList();

  /// Returns a list of tasks that are currently displayed to the user.
  List<Task> get displayedTasks => state.where((task) => task.display).toList();

  /// Sets a task's display property to true, making it visible in the active task list.
  Future<void> activateTask(Task task) async {
    if (task.activate()) {
      await updateTask(task);
    }
  }

  /// Handles the logic for when a user marks a task as complete.
  ///
  /// This method updates the streaks of any associated goals, records the
  /// completion for the current day, and then either deletes the task or
  /// hides it based on its properties.
  Future<void> markTaskDone(Task task) async {
    final goalNotifier = _ref.read(goalProvider.notifier);
    final goals = _ref.read(goalProvider);

    // Update streaks for all associated goals that haven't been updated today.
    for (String goalId in task.goalIds) {
      final goal = goals.firstWhereOrNull((g) => g.id == goalId);

      if (goal != null && !goal.updated) {
        await goalNotifier.addStreak(goal);
      }
    }

    // Record the completion and invalidate dependent providers to trigger UI updates.
    final today = DateUtil.now().toString();
    await _repository.recordTaskCompletion(today);
    _ref.invalidate(tasksCompletedTodayProvider);
    _ref.invalidate(weeklyCompletionsProvider);

    // Either delete the task or mark it as not displayed.
    if (task.shouldBeDeleted) {
      await deleteTask(task);
    } else {
      task.display = false;
      await updateTask(task);
    }
  }

  /// Selects a random task from the hidden tasks based on a weighted algorithm.
  ///
  /// The weight of each task is determined by its importance and how many times
  /// it has appeared, adjusted by a user setting. This ensures a balanced
  /// distribution of tasks over time.
  Task? getWeightedTask() {
    final activeTasks = hiddenTasks;
    if (activeTasks.isEmpty) return null;
    if (activeTasks.length == 1) return activeTasks.first;

    final currentWeight = _ref.read(settingsProvider).weight;
    int totalWeight = 0;
    final List<int> weights = [];

    for (final task in activeTasks) {
      final weightValue = _calculateTaskWeight(task, currentWeight);
      weights.add(weightValue);
      totalWeight += weightValue;
    }

    // If all weights are zero, return a purely random task to avoid errors.
    if (totalWeight == 0) {
      return activeTasks[Random().nextInt(activeTasks.length)];
    }

    // Pick a task based on the calculated weights.
    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;
    for (int i = 0; i < activeTasks.length; i++) {
      cumulativeWeight += weights[i];
      if (randomNumber < cumulativeWeight) {
        return activeTasks[i];
      }
    }
    return activeTasks.last; // Fallback in case of rounding errors.
  }

  /// Calculates a numerical weight for a task.
  /// The formula balances the task's appearance count and its importance.
  /// The `settingWeight` (from 1-10) adjusts the influence of the appearance count.
  int _calculateTaskWeight(Task task, int settingWeight) {
    final appearance = task.appearanceCount;
    final importance = task.importance;
    // An exponent derived from user settings to control appearance influence.
    final exponent = (5 - settingWeight).toDouble();
    // A component based on how many times the task has appeared.
    final appearanceComponent = pow(appearance, exponent) * 8;
    // A component based on the task's inherent importance.
    final importanceComponent = importance * 12;
    final totalWeight = (appearanceComponent + importanceComponent).toInt();
    // Clamp the weight to a reasonable range.
    return totalWeight.clamp(1, 1000);
  }

  /// Selects a task using the weighted algorithm and activates it.
  Future<bool> activateWeightedTask() async {
    final task = getWeightedTask();
    if (task != null) {
      await activateTask(task);
      return true;
    }
    return false;
  }
}

// --- Derived Providers ---

/// Provides the count of tasks that are currently displayed (i.e., not completed).
final tasksNotCompletedCountProvider = Provider<int>(
    (ref) => ref.watch(taskProvider.notifier).displayedTasks.length);

/// Provides a list of task completion counts for the last 7 days.
final weeklyCompletionsProvider =
    FutureProvider<List<DailyCompletion>>((ref) async {
  final repository = ref.watch(hiveRepositoryProvider);
  final now = DateUtil.now();
  List<DailyCompletion> completions = [];
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    completions.add(DailyCompletion(
        date: date, count: repository.getTaskCompletionCount(date.toString())));
  }
  return completions;
});

/// Provides the total number of goals.
final totalGoalsProvider =
    Provider<int>((ref) => ref.watch(goalProvider).length);

/// Computes and provides the longest streak among all goals.
final longestStreakProvider = Provider<int>((ref) {
  final goals = ref.watch(goalProvider);
  if (goals.isEmpty) return 0;
  return goals.map((g) => g.streak).reduce(max);
});

/// Provides the number of tasks completed today.
final tasksCompletedTodayProvider = Provider<int>((ref) {
  final repository = ref.watch(hiveRepositoryProvider);
  // Passing null gets the count for the current day.
  return repository.getTaskCompletionCount(null);
});

/// A simple data class to hold the completion count for a specific date.
class DailyCompletion {
  final DateTime date;
  final int count;
  DailyCompletion({required this.date, required this.count});
}
