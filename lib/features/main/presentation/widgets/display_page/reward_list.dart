// lib/features/main/presentation/widgets/reward_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/model/reward.dart';
import '../../../../../core/provider/reward.dart';

class RewardList extends ConsumerWidget {
  const RewardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardProvider);
    final rewardNotifier = ref.read(rewardProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rewards',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                    '${rewards.length} reward${rewards.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        )),
              ],
            ),
            const SizedBox(height: 16),
            rewards.isEmpty
                ? const _EmptyRewardsIndicator()
                : Column(
                    children: rewards
                        .map((reward) => RewardListItem(
                              reward: reward,
                              onDelete: () =>
                                  rewardNotifier.deleteReward(reward),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class RewardListItem extends ConsumerWidget {
  final Reward reward;
  final VoidCallback onDelete;

  const RewardListItem({
    super.key,
    required this.reward,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(26),
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          title: Text(
            reward.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reward.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    reward.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(178),
                        ),
                  ),
                ),
              Text(
                'Rarity: ${reward.rarity}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(153),
                    ),
              ),
            ],
          ),
          trailing: IconButton(
            icon:
                Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}

class _EmptyRewardsIndicator extends StatelessWidget {
  const _EmptyRewardsIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(Icons.card_giftcard_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102)),
            const SizedBox(height: 16),
            Text('No rewards created yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(153),
                    )),
          ],
        ),
      ),
    );
  }
}
