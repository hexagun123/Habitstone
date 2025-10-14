// core/data/hive.dart
// the hive repository for local data storage
import 'package:hive/hive.dart';
import '../model/goal.dart';
import '../model/task.dart';
import 'util.dart';
import '../theme/app_theme.dart';

// the repo class
class HiveRepository {
  // three boxes to be opened
  // goal task and daily - daily checks for statistics of daily completion
  // id to the box
  static const String _goalsBoxName = 'goals_box';
  static const String _tasksBoxName = 'tasks_box';
  static const String _dailyBoxName = 'daily_box';
  static const String _settingsBoxName = 'settings_box'; // New settings box

// boxes attribute
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

  // getters
  List<Goal> getGoals() => _goalsBox?.values.toList() ?? [];
  List<Task> getTasks() => _tasksBox?.values.toList() ?? [];

  // crud for goal and task
  Future<void> addGoal(Goal goal) async => await _goalsBox?.add(goal);
  Future<void> updateGoal(int key, Goal goal) async =>
      await _goalsBox?.put(key, goal);
  Future<void> deleteGoal(int key) async => await _goalsBox?.delete(key);

  Future<void> addTask(Task task) async => await _tasksBox?.add(task);
  Future<void> updateTask(int key, Task task) async =>
      await _tasksBox?.put(key, task);
  Future<void> deleteTask(int key) async => await _tasksBox?.delete(key);

  // function to call then task is completed
  // to record stats
  // can be on what ever date for later impletmentation of delayed task?
  Future<void> recordTaskCompletion(String date) async {
    final count = getTaskCompletionCount(date);

    // update the new value
    await _dailyBox!.put(date, {'count': count + 1});
  }

  // function to get the statistics
  // basically the same procedure
  int getTaskCompletionCount(String? date) {
    if (_dailyBox == null) return 0;

    date ??= DateUtil.now().toString();

    // Get data
    final dynamicData = _dailyBox!.get(date, defaultValue: {'count': 0});
    final Map data = dynamicData is Map ? dynamicData : {'count': 0};

    // extract value
    int count = (data['count'] is int)
        ? data['count'] as int
        : int.tryParse(data['count'].toString()) ?? 0;

    return count;
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
