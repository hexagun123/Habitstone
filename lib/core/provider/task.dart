// providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/task.dart';
import 'goal.dart';
import '../data/util.dart';
import '../provider/hive.dart';
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

  // Get tasks that are not displayed (for the popup)
  List<Task> get hiddenTasks {
    return state.where((task) => !task.display).toList();
  }

  // Get tasks that are displayed (for the task list)
  List<Task> get displayedTasks {
    return state.where((task) => task.display).toList();
  }

  // Activate a hidden task (set display = true and decrement appearance)
  Future<void> activateTask(Task task) async {
    if (task.activate()) {
      await updateTask(task);
    }
  }

  // Updated markTaskDone method to handle deletion when appearanceCount reaches 0
  Future<void> markTaskDone(Task task, WidgetRef ref) async {
    // Update linked goals
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

    // Record daily completion
    final today = DateUtil.now().toString();
    await repository.recordTaskCompletion(today);
    ref.invalidate(tasksCompletedTodayProvider);
    ref.invalidate(weeklyCompletionsProvider);

    // Delete task only if appearanceCount is 0, otherwise just update
    if (task.shouldBeDeleted) {
      await deleteTask(task);
    } else {
      // If there are still appearances left, keep the task but mark it as not displayed
      task.display = false;
      await updateTask(task);
    }
  }
}

// Update the provider to only count displayed tasks
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
