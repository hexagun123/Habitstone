// lib/core/data/hive_repository.dart
import 'package:hive/hive.dart';
import '../model/goal.dart';
import '../model/task.dart';
import 'util.dart';
import '../theme/app_theme.dart';

class HiveRepository {
  static const String _goalsBoxName = 'goals_box';
  static const String _tasksBoxName = 'tasks_box';
  static const String _dailyBoxName = 'daily_box';
  static const String _settingsBoxName = 'settings_box'; // New settings box

  Box<Goal>? _goalsBox;
  Box<Task>? _tasksBox;
  Box<Map>? _dailyBox;
  Box<Map>? _settingsBox; // New settings box

  // Initialize all boxes
  Future<void> init() async {
    _goalsBox = await Hive.openBox<Goal>(_goalsBoxName);
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _dailyBox = await Hive.openBox<Map>(_dailyBoxName);
    _settingsBox =
        await Hive.openBox<Map>(_settingsBoxName); // Initialize settings box
  }

  // Add null checks for all box accesses
  List<Goal> getGoals() => _goalsBox?.values.toList() ?? [];
  List<Task> getTasks() => _tasksBox?.values.toList() ?? [];

  Future<void> addGoal(Goal goal) async => await _goalsBox?.add(goal);
  Future<void> updateGoal(int key, Goal goal) async =>
      await _goalsBox?.put(key, goal);
  Future<void> deleteGoal(int key) async => await _goalsBox?.delete(key);

  Future<void> addTask(Task task) async => await _tasksBox?.add(task);
  Future<void> updateTask(int key, Task task) async =>
      await _tasksBox?.put(key, task);
  Future<void> deleteTask(int key) async => await _tasksBox?.delete(key);

  Future<void> recordTaskCompletion(String date) async {
    if (_dailyBox == null) return;

    // Get data as dynamic map and convert to proper types
    final dynamicData = _dailyBox!.get(date, defaultValue: {'count': 0});
    final Map data = dynamicData is Map ? dynamicData : {'count': 0};

    // Safely extract count value
    final count = (data['count'] is int)
        ? data['count'] as int
        : int.tryParse(data['count'].toString()) ?? 0;

    await _dailyBox!.put(date, {'count': count + 1});
  }

  int getTaskCompletionCount(String? date) {
    if (_dailyBox == null) return 0;
    date ??= DateUtil.toMidnight(DateTime.now().toUtc()).toString();
    final dynamicData = _dailyBox!.get(date, defaultValue: {'count': 0});
    final Map data = dynamicData is Map ? dynamicData : {'count': 0};

    return (data['count'] is int)
        ? data['count'] as int
        : int.tryParse(data['count'].toString()) ?? 0;
  }

  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _settingsBox?.put('theme', {'mode': mode.index});
  }

  AppThemeMode? getThemeMode() {
    final data = _settingsBox?.get('theme');
    if (data != null && data['mode'] is int) {
      final index = data['mode'] as int;
      if (index < AppThemeMode.values.length) {
        final mode = AppThemeMode.values[index];
        return mode;
      }
    }
    return null;
  }
}
