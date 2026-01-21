/// lib/core/data/hive.dart

import 'dart:async';
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
  Box<Goal>? _goalsBox;
  Box<Task>? _tasksBox;
  Box<Reward>? _rewardsBox;
  Box<Map>? _dailyBox;
  Box<Settings>? _settingsBox;

  // --- Initialization State Management ---
  // A completer to signal when initialization is fully finished.
  final Completer<void> _initCompleter = Completer<void>();

  /// Returns a Future that completes when init() has finished.
  /// Used by other services (like Sync) to ensure they don't access null boxes.
  Future<void> get waitForInitialization => _initCompleter.future;

  /// Initializes the repository by opening all required Hive boxes.
  /// This method must be called once at application startup.
  Future<void> init() async {
    // If already initialized or initializing, don't run again.
    if (_initCompleter.isCompleted) return;

    print("HiveRepository: Initializing boxes...");

    // Open all boxes
    _goalsBox = await Hive.openBox<Goal>(_goalsBoxName);
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _rewardsBox = await Hive.openBox<Reward>(_rewardsBoxName);
    _dailyBox = await Hive.openBox<Map>(_dailyBoxName);
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);

    print("HiveRepository: Initialization Complete. Boxes are open.");

    // Signal completion
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete();
    }
  }

  /// --- Helper to check initialization ---
  /// Throws or logs if a box is accessed before init() is complete.
  bool _checkBox(Box? box, String name) {
    if (box == null || !box.isOpen) {
      print(
          "HiveRepository Error: Attempted to access $name but it is CLOSED or NULL. Call init() first.");
      return false;
    }
    return true;
  }

  /// --- Settings Management ---

  /// Persists the provided `Settings` object to the settings box.
  Future<void> _saveSettings(Settings s) async {
    if (_checkBox(_settingsBox, 'SettingsBox')) {
      await _settingsBox!.put(_settingsKey, s);
    }
  }

  /// Retrieves the current `Settings` object. If none exists, it creates,
  /// saves, and returns a default `Settings` object.
  Settings getSettings() {
    // Return default if accessed too early to prevent crash
    if (_settingsBox == null || !_settingsBox!.isOpen) return Settings.create();

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

  Future<void> addGoal(Goal g) async {
    if (_checkBox(_goalsBox, 'GoalsBox')) {
      await _goalsBox!.put(g.id, g);
      print("HiveRepository: Added Goal ${g.id}");
    }
  }

  Future<void> updateGoal(String id, Goal g) async {
    if (_checkBox(_goalsBox, 'GoalsBox')) await _goalsBox!.put(id, g);
  }

  Future<void> deleteGoal(String id) async {
    if (_checkBox(_goalsBox, 'GoalsBox')) await _goalsBox!.delete(id);
  }

  // Task operations
  List<Task> getTasks() => _tasksBox?.values.toList() ?? [];

  Future<void> addTask(Task t) async {
    if (_checkBox(_tasksBox, 'TasksBox')) {
      await _tasksBox!.put(t.id, t);
      print("HiveRepository: Added Task ${t.id}");
    }
  }

  Future<void> updateTask(String id, Task t) async {
    if (_checkBox(_tasksBox, 'TasksBox')) await _tasksBox!.put(id, t);
  }

  Future<void> deleteTask(String id) async {
    if (_checkBox(_tasksBox, 'TasksBox')) await _tasksBox!.delete(id);
  }

  // Reward operations
  List<Reward> getRewards() => _rewardsBox?.values.toList() ?? [];

  Future<void> addReward(Reward r) async {
    if (_checkBox(_rewardsBox, 'RewardsBox')) {
      await _rewardsBox!.put(r.id, r);
      print("HiveRepository: Added Reward ${r.id}");
    }
  }

  Future<void> updateReward(String id, Reward r) async {
    if (_checkBox(_rewardsBox, 'RewardsBox')) await _rewardsBox!.put(id, r);
  }

  Future<void> deleteReward(String id) async {
    if (_checkBox(_rewardsBox, 'RewardsBox')) await _rewardsBox!.delete(id);
  }

  /// --- Box Getters ---
  /// Provide direct access to the boxes, useful for `watch()` functionality.
  Box<Goal>? get goalsBox => _goalsBox;
  Box<Task>? get tasksBox => _tasksBox;
  Box<Reward>? get rewardsBox => _rewardsBox;

  /// --- Daily Progress Tracking ---

  /// Increments the task completion count for a given date string.
  Future<void> recordTaskCompletion(String d) async {
    if (_checkBox(_dailyBox, 'DailyBox')) {
      await _dailyBox!.put(d, {'count': getTaskCompletionCount(d) + 1});
    }
  }

  /// Retrieves the task completion count for a specific date string.
  /// Defaults to the current day if the date is null.
  int getTaskCompletionCount(String? d) {
    if (_dailyBox == null || !_dailyBox!.isOpen) return 0;
    d ??= Util.now().toString();
    final data = _dailyBox!.get(d, defaultValue: {'count': 0}) as Map;
    return data['count'] as int;
  }

  /// --- Data Maintenance & Caching ---

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
    if (_goalsBox != null)
      await _goalsBox!.putAll({for (var g in goals) g.id: g});
    if (_tasksBox != null)
      await _tasksBox!.putAll({for (var t in tasks) t.id: t});
    if (_rewardsBox != null)
      await _rewardsBox!.putAll({for (var r in rewards) r.id: r});
  }
}
