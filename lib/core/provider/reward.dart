import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/reward.dart';
import 'app.dart';
import '../data/hive.dart';

final rewardProvider =
    StateNotifierProvider<RewardNotifier, List<Reward>>((ref) {
  return RewardNotifier(ref.watch(hiveRepositoryProvider));
});

class RewardNotifier extends StateNotifier<List<Reward>> {
  final HiveRepository _repository;

  RewardNotifier(this._repository) : super(_repository.getRewards());

  Future<void> _refresh() async => state = [..._repository.getRewards()];

  Future<void> createReward(Reward reward) async {
    await _repository.addReward(reward);
    await _refresh();
  }

  Future<void> updateReward(Reward updatedReward) async {
    await _repository.updateReward(updatedReward.id, updatedReward);
    await _refresh();
  }

  Future<void> deleteReward(Reward reward) async {
    await _repository.deleteReward(reward.id);
    await _refresh();
  }

  Reward? getRandomReward() {
    if (state.isEmpty) {
      return null;
    }
    if (state.length == 1) {
      return state.first;
    }

    int totalWeight = 0;
    for (final reward in state) {
      final rarity = reward.rarity > 0 ? reward.rarity : 1;
      totalWeight += 11 - rarity;
    }

    if (totalWeight == 0) {
      return state[Random().nextInt(state.length)];
    }

    final randomNumber = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;

    for (final reward in state) {
      final rarity = reward.rarity > 0 ? reward.rarity : 1;
      cumulativeWeight += 11 - rarity;
      if (randomNumber < cumulativeWeight) {
        return reward;
      }
    }
    return state.last;
  }
}