// features/main/presentation/widgets/general/task.dart
// This file defines an extension on the `TaskNotifier` to add a sophisticated,
// weighted random task selection mechanism. This feature is central to the app's
// ability to suggest relevant tasks to the user.

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/model/task.dart';
import '../../../../../../core/provider/setting.dart';
import '../../../../../../core/provider/task.dart';

/// An extension that adds weighted random selection logic to the [TaskNotifier].
///
/// This approach cleanly separates the complex randomization algorithm from the
/// core state management responsibilities of the `TaskNotifier`, promoting

/// better code organization and maintainability.
extension TaskRandomizer on TaskNotifier {
  /// Calculates and returns a single task from the available list using a
  /// weighted probability algorithm.
  ///
  /// This method serves as the core of the task suggestion feature. It ensures
  /// that task selection is not purely random but is intelligently biased
  /// based on several factors: a task's `appearanceCount` (how many times it
  /// has been part of a goal), its `importance` level, and a user-configurable
  /// `weight` setting. The algorithm is designed to balance the urgency of
  /// frequently appearing tasks with the priority of important ones.
  ///
  /// The weighting formula is:
  /// `total_weight = appearance^(5 - weight_setting) * 8 + importance * 12`
  ///
  /// - A `weight_setting` > 5 favors tasks with a higher `appearanceCount`.
  /// - A `weight_setting` < 5 favors tasks with a higher `importance`.
  /// - A `weight_setting` of 5 provides a balanced approach.
  ///
  /// Returns the selected [Task], or `null` if no tasks are available.
  Task? getWeightedTask(WidgetRef ref) {
    // Retrieve the list of tasks that are currently available for selection.
    final activeTasks = hiddenTasks;

    // Handle edge cases where a weighted calculation is unnecessary or impossible.
    if (activeTasks.isEmpty) return null;
    if (activeTasks.length == 1) return activeTasks.first;

    // Read the user's preference for balancing importance vs. frequency.
    final currentWeight = ref.read(settingsProvider).weight;
    int totalWeight = 0;
    final List<int> weights = [];

    // First pass: Calculate the individual weight for each task and the total weight.
    for (final task in activeTasks) {
      final weightValue = _calculateTaskWeight(task, currentWeight);
      weights.add(weightValue);
      totalWeight += weightValue;
    }

    // If all tasks have a weight of 0, fall back to a simple random selection.
    if (totalWeight == 0) {
      return activeTasks[Random().nextInt(activeTasks.length)];
    }

    // Generate a random number within the range of the total weight.
    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;

    // Second pass: Find which task corresponds to the random number.
    for (int i = 0; i < activeTasks.length; i++) {
      cumulativeWeight += weights[i];
      if (randomNumber < cumulativeWeight) {
        return activeTasks[i];
      }
    }

    // Fallback in the unlikely event of a calculation issue.
    return activeTasks.last;
  }

  /// Calculates the raw weight for a single task based on the core algorithm.
  ///
  /// This private helper function encapsulates the weighting formula, taking a
  /// task and the user's weight setting as input. It uses `pow` for the
  /// exponential component related to appearance count.
  ///
  /// Returns an integer weight, clamped between 1 and 1000 to ensure stability.
  int _calculateTaskWeight(Task task, int settingWeight) {
    final appearance = task.appearanceCount;
    final importance = task.importance;

    // The exponent dynamically adjusts the influence of the appearance count.
    final exponent = (5 - settingWeight).toDouble();

    // The appearance component grows exponentially based on the user's setting.
    final appearanceComponent = pow(appearance, exponent) * 8;
    // The importance component provides a linear weight boost.
    final importanceComponent = importance * 12;

    final totalWeight = (appearanceComponent + importanceComponent).toInt();

    // Clamp the result to a reasonable range to prevent extreme outliers.
    return totalWeight.clamp(1, 1000);
  }

  /// A convenience method to select and activate a weighted random task.
  ///
  /// This public method combines the selection logic of [getWeightedTask] with
  /// the state update logic of the `TaskNotifier`'s `activateTask` method.
  /// It provides a simple, single-call interface for the UI to request and
  /// display a new suggested task.
  ///
  /// Returns `true` if a task was successfully selected and activated,
  /// otherwise returns `false`.
  Future<bool> activateWeightedTask(WidgetRef ref) async {
    final task = getWeightedTask(ref);
    if (task != null) {
      await activateTask(task); // Trigger the state update.
      return true;
    }
    return false;
  }
}
