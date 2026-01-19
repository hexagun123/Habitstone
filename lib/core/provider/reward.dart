/// This file manages the state of rewards within the application using Riverpod.
/// It provides a `RewardNotifier` to handle creating, updating, deleting,
/// and randomly selecting rewards, interacting with the local Hive database.

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/reward.dart';
import 'app.dart';
import '../data/hive.dart';

/// watches the reward section from hive and allows functions below
final rewardProvider =
    StateNotifierProvider<RewardNotifier, List<Reward>>((ref) {
  return RewardNotifier(ref.watch(hiveRepositoryProvider));
});

/// state notifier for rewards, to allow functions that manipulates the list
class RewardNotifier extends StateNotifier<List<Reward>> {
  final HiveRepository _repository;

  /// grabbing only the data for rewards
  RewardNotifier(this._repository) : super(_repository.getRewards());

  /// Refreshes the current state by fetching the latest list of rewards from the repository.
  Future<void> _refresh() async => state = [..._repository.getRewards()];

  /// Adds a new reward to the repository and updates the state.
  Future<void> createReward(Reward reward) async {
    await _repository.addReward(reward);
    await _refresh(); 
  }

  /// Updates an existing reward in the repository and updates the state.
  Future<void> updateReward(Reward updatedReward) async {
    await _repository.updateReward(updatedReward.id, updatedReward);
    await _refresh(); 
  }

  /// Deletes a reward from the repository and updates the state.
  Future<void> deleteReward(Reward reward) async {
    await _repository.deleteReward(reward.id);
    await _refresh(); 
  }

  /// Selects a random reward from the current list based on a weighted algorithm.
  /// Rewards with a lower rarity value have a higherchance of being selected.

  Reward? getRandomReward() {

    // make sure that we are on the latest state
    _refresh();

    if (state.isEmpty) {
      return null; // No rewards to choose from.
    }
    if (state.length == 1) {
      return state.first; // returns the only one available
    }

    // Calculate the total weight of all rewards.
    // Rarity is inverted (1-10 scale): lower rarity number means higher weight (11 - rarity).
    int totalWeight = 0;
    for (final reward in state) {
      final rarity =
          reward.rarity > 0 ? reward.rarity : (reward.rarity < 11 ? reward.rarity : 10); 
          // rarity shouldn't be negative nor zero nor above 10
          // thus we clamp the values
      totalWeight +=
          11 - rarity; // the inverse calculation, the higher rarity the less weight
    }

    /// grabbing a random number between 0 and totalWeight
    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;

    /// Iterate through rewards, accumulating weight until the random number is met.
    for (final reward in state) {
      final rarity = reward.rarity > 0 ? reward.rarity : 1;
      cumulativeWeight += 11 - rarity;
      if (randomNumber < cumulativeWeight) {
        return reward; // Return the reward in the selected weight range.
      }
    }

    return state.last; // fallback in case if nothing was returned
  }
}
