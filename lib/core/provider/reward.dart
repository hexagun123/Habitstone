/// This file manages the state of rewards within the application using Riverpod.
/// It provides a `RewardNotifier` to handle creating, updating, deleting,
/// and randomly selecting rewards, interacting with the local Hive database.

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/reward.dart';
import 'app.dart';
import '../data/hive.dart';

/// Provides the `RewardNotifier` to the widget tree.
/// Widgets can use this provider to listen to the list of rewards
/// and to call methods for modifying reward data.
final rewardProvider =
    StateNotifierProvider<RewardNotifier, List<Reward>>((ref) {
  // The notifier is initialized with the HiveRepository instance.
  return RewardNotifier(ref.watch(hiveRepositoryProvider));
});

/// A `StateNotifier` that manages the list of `Reward` objects.
/// It encapsulates business logic for reward management and interacts
/// with the underlying data repository.
class RewardNotifier extends StateNotifier<List<Reward>> {
  final HiveRepository _repository;

  /// Initializes the notifier by loading the initial list of rewards from the repository.
  RewardNotifier(this._repository) : super(_repository.getRewards());

  /// Refreshes the current state by fetching the latest list of rewards from the repository.
  Future<void> _refresh() async => state = [..._repository.getRewards()];

  /// Adds a new reward to the repository and updates the state.
  Future<void> createReward(Reward reward) async {
    await _repository.addReward(reward);
    await _refresh(); // Refresh state to include the new reward.
  }

  /// Updates an existing reward in the repository and updates the state.
  Future<void> updateReward(Reward updatedReward) async {
    await _repository.updateReward(updatedReward.id, updatedReward);
    await _refresh(); // Refresh state to reflect the changes.
  }

  /// Deletes a reward from the repository and updates the state.
  Future<void> deleteReward(Reward reward) async {
    await _repository.deleteReward(reward.id);
    await _refresh(); // Refresh state to remove the deleted reward.
  }

  /// Selects a random reward from the current list based on a weighted algorithm.
  /// Rewards with a lower rarity value (e.g., 1 for "Common") have a higher
  /// chance of being selected.
  Reward? getRandomReward() {
    _refresh();
    if (state.isEmpty) {
      return null; // No rewards to choose from.
    }
    if (state.length == 1) {
      return state.first; // Only one reward available.
    }

    // Calculate the total weight of all rewards.
    // Rarity is inverted (1-10 scale): lower rarity number means higher weight (11 - rarity).
    int totalWeight = 0;
    for (final reward in state) {
      final rarity =
          reward.rarity > 0 ? reward.rarity : 1; // Ensure rarity is at least 1.
      totalWeight +=
          11 - rarity; // Common (1) gets 10 weight, Legendary (10) gets 1.
    }

    // If all rewards have invalid rarity leading to zero weight, pick one at random.
    if (totalWeight == 0) {
      return state[Random().nextInt(state.length)];
    }

    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;

    // Iterate through rewards, accumulating weight until the random number is met.
    for (final reward in state) {
      final rarity = reward.rarity > 0 ? reward.rarity : 1;
      cumulativeWeight += 11 - rarity;
      if (randomNumber < cumulativeWeight) {
        return reward; // Return the reward in the selected weight range.
      }
    }
    return state.last; // Fallback, should rarely be hit.
  }
}
