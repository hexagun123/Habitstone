import 'package:hive/hive.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';
import 'util.dart';
import '../theme/app_theme.dart';
import '../model/settings.dart';

class HiveRepository {
  // --- Unchanged Section ---
  static const String _goalsBoxName = 'goals_box';
  static const String _tasksBoxName = 'tasks_box';
  static const String _rewardsBoxName = 'rewards_box';
  static const String _dailyBoxName = 'daily_box';
  static const String _settingsBoxName = 'settings_box';

  // --- NEW: A constant key for our settings object ---
  static const String _settingsKey = 'current_settings';

  Box<Goal>? _goalsBox;
  Box<Task>? _tasksBox;
  Box<Reward>? _rewardsBox;
  Box<Map>? _dailyBox;
  Box<Settings>? _settingsBox;

  Future<void> init() async {
    _goalsBox = await Hive.openBox<Goal>(_goalsBoxName);
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _rewardsBox = await Hive.openBox<Reward>(_rewardsBoxName);
    _dailyBox = await Hive.openBox<Map>(_dailyBoxName);
    // The settings box now stores a plain Settings object, not a HiveObject
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
  }

  // --- REWRITTEN SETTINGS LOGIC ---

  /// Saves the provided settings object to the box with a fixed key.
  Future<void> _saveSettings(Settings settings) async {
    await _settingsBox?.put(_settingsKey, settings);
  }

  /// Gets the settings object. If it doesn't exist, it creates, saves, and returns it.
  Settings getSettings() {
    // Try to get the settings object using our constant key.
    final settings = _settingsBox?.get(_settingsKey);
    if (settings == null) {
      print("No settings found, creating defaults.");
      final defaultSettings = Settings.create();
      // Save the new default settings for next time.
      _saveSettings(defaultSettings);
      return defaultSettings;
    }
    return settings;
  }

  /// Updates the theme using the "get-copy-save" pattern.
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final currentSettings = getSettings();
    // Create a new, updated copy.
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    // Save the new copy, overwriting the old one.
    await _saveSettings(updatedSettings);
  }

  /// Updates the weight using the "get-copy-save" pattern.
  Future<void> updateWeight(int weight) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(weight: weight);
    await _saveSettings(updatedSettings);
  }

  // --- The rest of the file is correct and unchanged ---
  List<Goal> getGoals() => _goalsBox?.values.toList() ?? [];
  List<Task> getTasks() => _tasksBox?.values.toList() ?? [];
  List<Reward> getRewards() => _rewardsBox?.values.toList() ?? [];

  Future<void> addGoal(Goal goal) async => await _goalsBox?.put(goal.id, goal);
  Future<void> updateGoal(String id, Goal goal) async =>
      await _goalsBox?.put(id, goal);
  Future<void> deleteGoal(String id) async => await _goalsBox?.delete(id);

  Future<void> addTask(Task task) async => await _tasksBox?.put(task.id, task);
  Future<void> updateTask(String id, Task task) async =>
      await _tasksBox?.put(id, task);
  Future<void> deleteTask(String id) async => await _tasksBox?.delete(id);

  Future<void> addReward(Reward reward) async =>
      await _rewardsBox?.put(reward.id, reward);
  Future<void> updateReward(String id, Reward reward) async =>
      await _rewardsBox?.put(id, reward);
  Future<void> deleteReward(String id) async => await _rewardsBox?.delete(id);
  Box<Goal>? get goalsBox => _goalsBox;
  Box<Task>? get tasksBox => _tasksBox;
  Box<Reward>? get rewardsBox => _rewardsBox;

  // --- STATS METHODS ---
  Future<void> recordTaskCompletion(String date) async {
    final count = getTaskCompletionCount(date);
    await _dailyBox!.put(date, {'count': count + 1});
  }

  int getTaskCompletionCount(String? date) {
    if (_dailyBox == null) return 0;
    date ??= DateUtil.now().toString();
    final dynamicData = _dailyBox!.get(date, defaultValue: {'count': 0});
    final Map data = dynamicData is Map ? dynamicData : {'count': 0};
    int count = (data['count'] is int)
        ? data['count'] as int
        : int.tryParse(data['count'].toString()) ?? 0;
    return count;
  }

  // --- SYNC & UTILITY METHODS ---
  Future<void> clearCorruptedSettings() async {
    try {
      await _settingsBox?.close();
      await Hive.deleteBoxFromDisk(_settingsBoxName);
      _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
      if (_settingsBox!.isEmpty) {
        await _settingsBox!.add(Settings.create());
      }
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }

  Future<void> cacheAllData({
    required List<Goal> goals,
    required List<Task> tasks,
    required List<Reward> rewards,
  }) async {
    await _goalsBox?.clear();
    await _tasksBox?.clear();
    await _rewardsBox?.clear();

    await _goalsBox?.putAll({for (var g in goals) g.id: g});
    await _tasksBox?.putAll({for (var t in tasks) t.id: t});
    await _rewardsBox?.putAll({for (var r in rewards) r.id: r});
  }
}
