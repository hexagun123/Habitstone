// providers/task_randomizer.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../../../core/provider/task.dart';
import '../../../../../core/provider/setting.dart';
import '../../../../../core/model/task.dart';

extension TaskRandomizer on TaskNotifier {
  /// Selects a random task using weighted probability based on:
  /// - Appearance count (higher = more urgent)
  /// - Importance (higher = more important) 
  /// - Weight setting from app settings (controls balance between length vs importance)
  ///
  /// Formula: total_weight = appearance^(5 - weight) * 8 + importance * 12
  ///
  /// When weight > 5: Favors tasks with higher appearance count (longer tasks)
  /// When weight < 5: Favors tasks with higher importance (important but shorter tasks)
  /// When weight = 5: Balanced approach
  Task? getWeightedTask(WidgetRef ref) {
    final activeTasks = hiddenTasks;
    
    if (activeTasks.isEmpty) return null;
    if (activeTasks.length == 1) return activeTasks.first;

    final currentWeight = ref.read(settingsProvider).weight;
    int totalWeight = 0;
    final List<int> weights = [];

    for (final task in activeTasks) {
      final weightValue = _calculateTaskWeight(task, currentWeight);
      weights.add(weightValue);
      totalWeight += weightValue;
    }

    if (totalWeight == 0) {
      return activeTasks[Random().nextInt(activeTasks.length)];
    }

    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;

    for (int i = 0; i < activeTasks.length; i++) {
      cumulativeWeight += weights[i];
      if (randomNumber < cumulativeWeight) {
        return activeTasks[i];
      }
    }

    return activeTasks.last;
  }

  int _calculateTaskWeight(Task task, int settingWeight) {
    final appearance = task.appearanceCount;
    final importance = task.importance;
    
    final exponent = (5 - settingWeight).toDouble();
    final appearanceComponent = pow(appearance, exponent) * 8;
    final importanceComponent = importance * 12;
    
    final totalWeight = (appearanceComponent + importanceComponent).toInt();
    
    return totalWeight.clamp(1, 1000);
  }

  /// Activates a random weighted task for display
  Future<bool> activateWeightedTask(WidgetRef ref) async {
    final task = getWeightedTask(ref);
    if (task != null) {
      await activateTask(task);
      return true;
    }
    return false;
  }
}