// lib/core/providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local.dart';
import '../model/task.dart';

final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepository();
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final repository = ref.watch(dataRepositoryProvider);
  return TasksNotifier(repository);
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final DataRepository _repository;

  TasksNotifier(this._repository) : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    state = await _repository.loadTasks();
  }

  Future<void> addTask(Task newTask) async {
    state = [...state, newTask];
    await _repository.saveTasks(state);
  }

  Future<void> updateTask(Task updatedTask) async {
    state = state
        .map((task) => task.id == updatedTask.id ? updatedTask : task)
        .toList();
    await _repository.saveTasks(state);
  }

  Future<void> deleteTask(String taskId) async {
    state = state.where((task) => task.id != taskId).toList();
    await _repository.saveTasks(state);
  }
}
