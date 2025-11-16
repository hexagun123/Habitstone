/// This file defines the `HiveRepository`, a centralized class for managing all
/// interactions with the local Hive database. It encapsulates CRUD operations
/// for all data models (Goals, Tasks, Rewards, Settings) and handles the
/// initialization and clearing of Hive boxes.

import 'package:hive/hive.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';
import 'util.dart';
import '../theme/app_theme.dart';
import '../model/settings.dart';

class HiveRepository {
  // --- Box Names ---
  // Defines constant names for each Hive box to prevent typos.
  static const String _goalsBoxName = 'goals_box';
  static const String _tasksBoxName = 'tasks_box';
  static const String _rewardsBoxName = 'rewards_box';
  static const String _dailyBoxName = 'daily_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _settingsKey = 'current_settings';

  // --- Private Box Instances ---
  // These will hold the opened Hive boxes after initialization.
  Box<Goal>? _goalsBox;
  Box<Task>? _tasksBox;
  Box<Reward>? _rewardsBox;
  Box<Map>? _dailyBox;
  Box<Settings>? _settingsBox;

  /// Initializes the repository by opening all required Hive boxes.
  /// This method must be called once at application startup before any other
  /// repository methods are used.
  Future<void> init() async {
    _goalsBox = await Hive.openBox<Goal>(_goalsBoxName);
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _rewardsBox = await Hive.openBox<Reward>(_rewardsBoxName);
    _dailyBox = await Hive.openBox<Map>(_dailyBoxName);
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
  }

  /// --- Settings Management ---

  /// Persists the provided `Settings` object to the settings box.
  Future<void> _saveSettings(Settings s) async =>
      await _settingsBox?.put(_settingsKey, s);

  /// Retrieves the current `Settings` object. If none exists, it creates,
  /// saves, and returns a default `Settings` object.
  Settings getSettings() {
    final s = _settingsBox?.get(_settingsKey);
    if (s == null) {
      final d = Settings.create();
      _saveSettings(d);
      return d;
    }
    return s;
  }

  /// Updates and saves the application's theme mode.
  Future<void> updateThemeMode(AppThemeMode m) async =>
      await _saveSettings(getSettings().copyWith(themeMode: m));

  /// Updates and saves the user's selected weight setting.
  Future<void> updateWeight(int w) async =>
      await _saveSettings(getSettings().copyWith(weight: w));

  /// --- CRUD Operations for Goals, Tasks, Rewards ---

  // Goal operations
  List<Goal> getGoals() => _goalsBox?.values.toList() ?? [];
  Future<void> addGoal(Goal g) async => await _goalsBox?.put(g.id, g);
  Future<void> updateGoal(String id, Goal g) async =>
      await _goalsBox?.put(id, g);
  Future<void> deleteGoal(String id) async => await _goalsBox?.delete(id);

  // Task operations
  List<Task> getTasks() => _tasksBox?.values.toList() ?? [];
  Future<void> addTask(Task t) async => await _tasksBox?.put(t.id, t);
  Future<void> updateTask(String id, Task t) async =>
      await _tasksBox?.put(id, t);
  Future<void> deleteTask(String id) async => await _tasksBox?.delete(id);

  // Reward operations
  List<Reward> getRewards() => _rewardsBox?.values.toList() ?? [];
  Future<void> addReward(Reward r) async => await _rewardsBox?.put(r.id, r);
  Future<void> updateReward(String id, Reward r) async =>
      await _rewardsBox?.put(id, r);
  Future<void> deleteReward(String id) async => await _rewardsBox?.delete(id);

  /// --- Box Getters ---
  /// Provide direct access to the boxes, useful for `watch()` functionality.
  Box<Goal>? get goalsBox => _goalsBox;
  Box<Task>? get tasksBox => _tasksBox;
  Box<Reward>? get rewardsBox => _rewardsBox;

  /// --- Daily Progress Tracking ---

  /// Increments the task completion count for a given date string.
  Future<void> recordTaskCompletion(String d) async =>
      await _dailyBox!.put(d, {'count': getTaskCompletionCount(d) + 1});

  /// Retrieves the task completion count for a specific date string.
  /// Defaults to the current day if the date is null.
  int getTaskCompletionCount(String? d) {
    d ??= DateUtil.now().toString();
    final data = _dailyBox!.get(d, defaultValue: {'count': 0}) as Map;
    return data['count'] as int;
  }

  /// --- Data Maintenance & Caching ---

  /// Deletes the settings box from disk. A recovery mechanism for corrupted data.
  Future<void> clearCorruptedSettings() async =>
      await _settingsBox?.deleteFromDisk();

  /// Clears all user-specific data (goals, tasks, rewards) from the database.
  /// Typically used during user logout.
  Future<void> clearAllBoxes() async {
    await _goalsBox?.clear();
    await _tasksBox?.clear();
    await _rewardsBox?.clear();
  }

  /// Replaces the entire local cache with new data from a remote source.
  /// It first clears existing data and then populates the boxes with the provided lists.
  Future<void> cacheAllData({
    required List<Goal> goals,
    required List<Task> tasks,
    required List<Reward> rewards,
  }) async {
    await clearAllBoxes(); // Clear existing data before caching.
    // Use putAll for efficient bulk insertion.
    await _goalsBox?.putAll({for (var g in goals) g.id: g});
    await _tasksBox?.putAll({for (var t in tasks) t.id: t});
    await _rewardsBox?.putAll({for (var r in rewards) r.id: r});
  }
}
