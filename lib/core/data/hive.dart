// core/data/hive.dart
// the hive repository for local data storage
import 'package:hive/hive.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart'; // Import the Reward model
import 'util.dart';
import '../theme/app_theme.dart';
import '../model/settings.dart';

// the repo class
class HiveRepository {
  // three boxes to be opened
  // goal task and daily - daily checks for statistics of daily completion
  // id to the box
  static const String _goalsBoxName = 'goals_box';
  static const String _tasksBoxName = 'tasks_box';
  static const String _rewardsBoxName = 'rewards_box'; // New rewards box name
  static const String _dailyBoxName = 'daily_box';
  static const String _settingsBoxName = 'settings_box';

// boxes attribute
  Box<Goal>? _goalsBox;
  Box<Task>? _tasksBox;
  Box<Reward>? _rewardsBox; // New rewards box attribute
  Box<Map>? _dailyBox;
  Box<Settings>? _settingsBox;

  // Update init method
  Future<void> init() async {
    _goalsBox = await Hive.openBox<Goal>(_goalsBoxName);
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _rewardsBox = await Hive.openBox<Reward>(_rewardsBoxName);
    _dailyBox = await Hive.openBox<Map>(_dailyBoxName);
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);

    // Initialize default setting if none exist
  }

  Settings getSettings() {
    try {
      if (_settingsBox == null || _settingsBox!.isEmpty) {
        return Settings.create();
      }

      final dynamic data = _settingsBox!.values.first;

      // Double-check it's actually a Settings object
      if (data is Settings) {
        return data;
      } else {
        print('Warning: Expected Settings but got ${data.runtimeType}');
        return Settings.create();
      }
    } catch (e) {
      print('Error in getSettings: $e');
      return Settings.create();
    }
  }

  Future<void> updateSettings(Settings settings) async {
    if (_settingsBox!.isNotEmpty) {
      final key = _settingsBox!.keys.first;
      await _settingsBox!.put(key, settings);
    } else {
      await _settingsBox!.add(settings);
    }
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    await updateSettings(updatedSettings);
  }

  Future<void> updateWeight(int weight) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(weight: weight);
    await updateSettings(updatedSettings);
  }

  // getters
  List<Goal> getGoals() => _goalsBox?.values.toList() ?? [];
  List<Task> getTasks() => _tasksBox?.values.toList() ?? [];
  List<Reward> getRewards() =>
      _rewardsBox?.values.toList() ?? []; // New rewards getter

  // crud for goal and task
  Future<void> addGoal(Goal goal) async => await _goalsBox?.add(goal);
  Future<void> updateGoal(int key, Goal goal) async =>
      await _goalsBox?.put(key, goal);
  Future<void> deleteGoal(int key) async => await _goalsBox?.delete(key);

  Future<void> addTask(Task task) async => await _tasksBox?.add(task);
  Future<void> updateTask(int key, Task task) async =>
      await _tasksBox?.put(key, task);
  Future<void> deleteTask(int key) async => await _tasksBox?.delete(key);

  // --- CRUD for Reward ---
  Future<void> addReward(Reward reward) async => await _rewardsBox?.add(reward);
  Future<void> updateReward(int key, Reward reward) async =>
      await _rewardsBox?.put(key, reward);
  Future<void> deleteReward(int key) async => await _rewardsBox?.delete(key);

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

  // In HiveRepository class
  Future<void> clearCorruptedSettings() async {
    try {
      await _settingsBox?.close();
      await Hive.deleteBoxFromDisk(_settingsBoxName);
      _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);

      // Initialize with default settings
      if (_settingsBox!.isEmpty) {
        await _settingsBox!.add(Settings.create());
      }
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }
}
