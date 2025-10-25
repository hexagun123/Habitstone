// providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math'; // Add this import
import '../model/task.dart';
import 'goal.dart';
import '../data/util.dart';
import '../provider/hive.dart';
import '../provider/setting.dart'; // Add this import
import '../../main.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.read(hiveRepositoryProvider));
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier(repository) : super(repository.getTasks());

  Future<void> _refresh() async {
    state = [...repository.getTasks()];
  }

  Future<void> createTask(Task task) async {
    await repository.addTask(task);
    await _refresh();
  }

  Future<void> updateTask(Task task) async {
    final key = task.key;
    if (key != null) {
      await repository.updateTask(key, task);
      await _refresh();
    }
  }

  Future<void> deleteTask(Task task) async {
    final key = task.key;
    if (key != null) {
      await repository.deleteTask(key);
      await _refresh();
    }
  }

  List<Task> get hiddenTasks {
    return state.where((task) => !task.display).toList();
  }

  List<Task> get displayedTasks {
    return state.where((task) => task.display).toList();
  }

  Future<void> activateTask(Task task) async {
    if (task.activate()) {
      await updateTask(task);
    }
  }

  Future<void> markTaskDone(Task task, WidgetRef ref) async {
    final goalNotifier = ref.read(goalProvider.notifier);
    final goals = ref.read(goalProvider);

    for (int goalId in task.goalIds) {
      final goalIndex = goals.indexWhere((goal) => goal.key == goalId);
      if (goalIndex != -1) {
        if (!goals[goalIndex].updated) {
          await goalNotifier.addStreak(goals[goalIndex]);
        }
      }
    }

    final today = DateUtil.now().toString();
    await repository.recordTaskCompletion(today);
    ref.invalidate(tasksCompletedTodayProvider);
    ref.invalidate(weeklyCompletionsProvider);

    if (task.shouldBeDeleted) {
      await deleteTask(task);
    } else {
      task.display = false;
      await updateTask(task);
    }
  }

  Task? getWeightedTask(WidgetRef ref) {
    final activeTasks = hiddenTasks;

    if (activeTasks.isEmpty) return null;
    if (activeTasks.length == 1) return activeTasks.first;

    final currentWeight = ref.read(settingsProvider).weight;
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

  /// Activates a random weighted task for display
  Future<bool> activateWeightedTask(WidgetRef ref) async {
    final task = getWeightedTask(ref);
    if (task != null) {
      await activateTask(task);
      return true;
    }
    return false;
  }
}

final tasksNotCompletedCountProvider = Provider<int>((ref) {
  return ref.watch(taskProvider.notifier).displayedTasks.length;
});

final weeklyCompletionsProvider =
    FutureProvider<List<DailyCompletion>>((ref) async {
  final repository = ref.read(hiveRepositoryProvider);
  final now = DateUtil.now();
  List<DailyCompletion> completions = [];

  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    completions.add(DailyCompletion(
        date: date, count: repository.getTaskCompletionCount(date.toString())));
  }

  return completions;
});

final totalGoalsProvider = Provider<int>((ref) {
  return ref.watch(goalProvider).length;
});

final longestStreakProvider = Provider<int>((ref) {
  final goals = ref.watch(goalProvider);
  if (goals.isEmpty) return 0;
  return goals.map((g) => g.streak).reduce((a, b) => a > b ? a : b);
});

final tasksCompletedTodayProvider = Provider<int>((ref) {
  return repository.getTaskCompletionCount(null);
});

class DailyCompletion {
  final DateTime date;
  final int count;

  DailyCompletion({required this.date, required this.count});
}
