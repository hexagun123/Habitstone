// providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';
import '../model/task.dart';
import 'goal.dart';
import '../data/util.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.read(hiveRepositoryProvider));
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final HiveRepository _repository;
  int _tasksCompletedToday = 0;

  TaskNotifier(this._repository) : super(_repository.getTasks());

  int get tasksCompletedToday => _tasksCompletedToday;

  Future<void> _refresh() async {
    state = [..._repository.getTasks()];
  }

  Future<void> createTask(Task task) async {
    await _repository.addTask(task);
    await _refresh();
  }

  Future<void> updateTask(Task task) async {
    final key = task.key;
    if (key != null) {
      await _repository.updateTask(key, task);
      await _refresh();
    }
  }

  Future<void> deleteTask(Task task) async {
    final key = task.key;
    if (key != null) {
      await _repository.deleteTask(key);
      await _refresh();
    }
  }

// In markTaskDone method:
  Future<void> markTaskDone(Task task, WidgetRef ref) async {
    // Update linked goals
    final goalNotifier = ref.read(goalProvider.notifier);
    final goals = ref.read(goalProvider);

    for (int goalId in task.goalIds) {
      final goalIndex = goals.indexWhere((goal) => goal.key == goalId);
      if (goalIndex != -1) {
        await goalNotifier.markGoalAsUpdated(goals[goalIndex]);
      }
    }

    // Record daily completion
    final today = DateUtil.toMidnight(DateTime.now()).toString();
    await _repository.recordTaskCompletion(today);

    await deleteTask(task);
  }

  Future<void> addGoalToTask(Task task, int goalId) async {
    task.addGoal(goalId);
    await updateTask(task);
  }

  Future<void> removeGoalFromTask(Task task, int goalId) async {
    task.removeGoal(goalId);
    await updateTask(task);
  }

  void resetDailyCounters() => _tasksCompletedToday = 0;
}

// Derived providers
final tasksCompletedTodayProvider = Provider<int>((ref) {
  return ref.watch(taskProvider.notifier).tasksCompletedToday;
});

final tasksNotCompletedCountProvider = Provider<int>((ref) {
  return ref.watch(taskProvider).length;
});

// task_provider.dart
// Add this after existing providers

final weeklyCompletionsProvider = FutureProvider<List<int>>((ref) async {
  final repository = ref.read(hiveRepositoryProvider);
  final now = DateTime.now().toUtc();
  final today = DateUtil.toMidnight(now);
  List<int> completions = [];

  for (int i = 6; i >= 0; i--) {
    final date = today.subtract(Duration(days: i)).toString();
    completions.add(repository.getTaskCompletionCount(date));
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
