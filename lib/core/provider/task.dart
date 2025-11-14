import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../model/task.dart';
import 'goal.dart';
import '../data/util.dart';
import 'app.dart';
import 'setting.dart';
import '../data/hive.dart';
import 'package:collection/collection.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.watch(hiveRepositoryProvider), ref);
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final HiveRepository _repository;
  final Ref _ref;

  TaskNotifier(this._repository, this._ref) : super(_repository.getTasks());

  Future<void> _refresh() async => state = [..._repository.getTasks()];

  Future<void> createTask(Task task) async {
    await _repository.addTask(task);
    await _refresh();
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task.id, task);
    await _refresh();
  }

  Future<void> deleteTask(Task task) async {
    await _repository.deleteTask(task.id);
    await _refresh();
  }

  List<Task> get hiddenTasks => state.where((task) => !task.display).toList();
  List<Task> get displayedTasks => state.where((task) => task.display).toList();

  Future<void> activateTask(Task task) async {
    if (task.activate()) {
      await updateTask(task);
    }
  }

  Future<void> markTaskDone(Task task) async {
    final goalNotifier = _ref.read(goalProvider.notifier);
    final goals = _ref.read(goalProvider);

    for (String goalId in task.goalIds) {
      final goal = goals.firstWhereOrNull((g) => g.id == goalId);

      if (goal != null && !goal.updated) {
        await goalNotifier.addStreak(goal);
      }
    }

    final today = DateUtil.now().toString();
    await _repository.recordTaskCompletion(today);
    _ref.invalidate(tasksCompletedTodayProvider);
    _ref.invalidate(weeklyCompletionsProvider);

    if (task.shouldBeDeleted) {
      await deleteTask(task);
    } else {
      task.display = false;
      await updateTask(task);
    }
  }

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

    if (totalWeight == 0) {
      return activeTasks[Random().nextInt(activeTasks.length)];
    }

    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;
    for (int i = 0; i < activeTasks.length; i++) {
      cumulativeWeight += weights[i];
      if (randomNumber < cumulativeWeight) {
        return activeTasks[i];
      }
    }
    return activeTasks.last;
  }

  int _calculateTaskWeight(Task task, int settingWeight) {
    final appearance = task.appearanceCount;
    final importance = task.importance;
    final exponent = (5 - settingWeight).toDouble();
    final appearanceComponent = pow(appearance, exponent) * 8;
    final importanceComponent = importance * 12;
    final totalWeight = (appearanceComponent + importanceComponent).toInt();
    return totalWeight.clamp(1, 1000);
  }

  Future<bool> activateWeightedTask() async {
    final task = getWeightedTask();
    if (task != null) {
      await activateTask(task);
      return true;
    }
    return false;
  }
}

final tasksNotCompletedCountProvider = Provider<int>(
    (ref) => ref.watch(taskProvider.notifier).displayedTasks.length);

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

final totalGoalsProvider =
    Provider<int>((ref) => ref.watch(goalProvider).length);

final longestStreakProvider = Provider<int>((ref) {
  final goals = ref.watch(goalProvider);
  if (goals.isEmpty) return 0;
  return goals.map((g) => g.streak).reduce(max);
});

final tasksCompletedTodayProvider = Provider<int>((ref) {
  final repository = ref.watch(hiveRepositoryProvider);
  return repository.getTaskCompletionCount(null);
});

class DailyCompletion {
  final DateTime date;
  final int count;
  DailyCompletion({required this.date, required this.count});
}
