import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive.dart';
import '../model/reward.dart';
import '../provider/hive.dart';

final rewardProvider =
    StateNotifierProvider<RewardNotifier, List<Reward>>((ref) {
  return RewardNotifier(ref.read(hiveRepositoryProvider));
});

class RewardNotifier extends StateNotifier<List<Reward>> {
  final HiveRepository _repository;

  RewardNotifier(this._repository) : super(_repository.getRewards());

  Future<void> _refresh() async {
    state = [..._repository.getRewards()];
  }

  // --- CRUD Operations ---

  Future<void> createReward(Reward reward) async {
    await _repository.addReward(reward);
    await _refresh();
  }

  Future<void> updateReward(Reward reward, Reward updatedReward) async {
    final key = reward.key;
    if (key != null) {
      await _repository.updateReward(key, updatedReward);
      await _refresh();
    }
  }

  Future<void> deleteReward(Reward reward) async {
    final key = reward.key;
    if (key != null) {
      await _repository.deleteReward(key);
      await _refresh();
    }
  }

  // --- Random Reward Generation ---

  /// Selects a random reward using a weighted probability system based on rarity.
  ///
  /// The selection logic is designed so that the probability of choosing a reward
  /// follows a geometric progression based on its rarity value. Specifically, a
  /// reward with rarity `R` is twice as likely to be selected as a reward with
  /// rarity `R+1`.
  ///
  /// For example:
  /// - A reward with rarity 1 is twice as likely as a rarity 2 reward.
  /// - A reward with rarity 2 is twice as likely as a rarity 3 reward.
  ///
  /// If multiple rewards share the same rarity, they each have the same individual
  /// chance of being selected. This means that the overall chance of getting a reward
  /// of a certain rarity increases if you have more rewards of that rarity.
  ///
  /// Returns `null` if the list of rewards is empty.
  Reward? getRandomReward() {
    // Handle edge cases where there are no rewards or only one.
    if (state.isEmpty) {
      return null;
    }
    if (state.length == 1) {
      return state.first;
    }

    int totalWeight = 0;
    for (final reward in state) {
      final rarity = reward.rarity > 0 ? reward.rarity : 1;
      totalWeight += 11-rarity;
    }

    // This is an unlikely edge case (e.g., if all rarities are invalid).
    // Fallback to a completely random, unweighted choice to prevent crashing.
    if (totalWeight == 0) {
      return state[Random().nextInt(state.length)];
    }

    // Step 3: Pick a random number somewhere within the range of the total weight.
    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;

    // Step 4: Iterate through the rewards again. The first reward that brings the
    // cumulative weight over the random number is the chosen one.
    for (final reward in state) {
      final rarity = reward.rarity > 0 ? reward.rarity : 1;

      cumulativeWeight += 11-rarity;

      if (randomNumber < cumulativeWeight) {
        return reward;
      }
    }

    // This fallback should theoretically not be reached but is here for safety.
    return state.last;
  }
}
