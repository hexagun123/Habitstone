// lib/core/data/hive.dart

import 'package:hive/hive.dart';
import '../model/goal.dart';
import '../model/task.dart';
import '../model/reward.dart';
import 'util.dart';
import '../theme/app_theme.dart';
import '../model/settings.dart';

class HiveRepository {
  static const String _goalsBoxName = 'goals_box';
  static const String _tasksBoxName = 'tasks_box';
  static const String _rewardsBoxName = 'rewards_box';
  static const String _dailyBoxName = 'daily_box';
  static const String _settingsBoxName = 'settings_box';
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
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);
  }

  Future<void> _saveSettings(Settings s) async => await _settingsBox?.put(_settingsKey, s);
  Settings getSettings() {
    final s = _settingsBox?.get(_settingsKey);
    if (s == null) {
      final d = Settings.create();
      _saveSettings(d);
      return d;
    }
    return s;
  }
  Future<void> updateThemeMode(AppThemeMode m) async => await _saveSettings(getSettings().copyWith(themeMode: m));
  Future<void> updateWeight(int w) async => await _saveSettings(getSettings().copyWith(weight: w));
  List<Goal> getGoals() => _goalsBox?.values.toList() ?? [];
  List<Task> getTasks() => _tasksBox?.values.toList() ?? [];
  List<Reward> getRewards() => _rewardsBox?.values.toList() ?? [];
  Future<void> addGoal(Goal g) async => await _goalsBox?.put(g.id, g);
  Future<void> updateGoal(String id, Goal g) async => await _goalsBox?.put(id, g);
  Future<void> deleteGoal(String id) async => await _goalsBox?.delete(id);
  Future<void> addTask(Task t) async => await _tasksBox?.put(t.id, t);
  Future<void> updateTask(String id, Task t) async => await _tasksBox?.put(id, t);
  Future<void> deleteTask(String id) async => await _tasksBox?.delete(id);
  Future<void> addReward(Reward r) async => await _rewardsBox?.put(r.id, r);
  Future<void> updateReward(String id, Reward r) async => await _rewardsBox?.put(id, r);
  Future<void> deleteReward(String id) async => await _rewardsBox?.delete(id);
  Box<Goal>? get goalsBox => _goalsBox;
  Box<Task>? get tasksBox => _tasksBox;
  Box<Reward>? get rewardsBox => _rewardsBox;
  Future<void> recordTaskCompletion(String d) async => await _dailyBox!.put(d, {'count': getTaskCompletionCount(d) + 1});
  int getTaskCompletionCount(String? d) {
    d ??= DateUtil.now().toString();
    final data = _dailyBox!.get(d, defaultValue: {'count': 0}) as Map;
    return data['count'] as int;
  }
  Future<void> clearCorruptedSettings() async => await _settingsBox?.deleteFromDisk();

  Future<void> clearAllBoxes() async {
    await _goalsBox?.clear();
    await _tasksBox?.clear();
    await _rewardsBox?.clear();
  }

  Future<void> cacheAllData({
    required List<Goal> goals,
    required List<Task> tasks,
    required List<Reward> rewards,
  }) async {
    await clearAllBoxes();
    await _goalsBox?.putAll({for (var g in goals) g.id: g});
    await _tasksBox?.putAll({for (var t in tasks) t.id: t});
    await _rewardsBox?.putAll({for (var r in rewards) r.id: r});
  }
}