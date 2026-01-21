// lib/features/main/presentation/widgets/reward_list.dart
// This file defines the UI components responsible for displaying the user's
// list of created rewards. It includes the main list container, individual
// list items, and a placeholder for when the list is empty.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/model/reward.dart';
import '../../../../../../core/provider/reward.dart';

/// A widget that displays the complete list of user-defined rewards in a card.
///
/// This [ConsumerWidget] subscribes to the `rewardProvider` to stay updated
/// with the current list of rewards. It dynamically renders either the list
/// of rewards or a placeholder message if no rewards have been created.
class RewardList extends ConsumerWidget {
  const RewardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the list and rebuild when it changes.
    final rewards = ref.watch(rewardProvider);
    // Read the notifier to access methods like `deleteReward`.
    final rewardNotifier = ref.read(rewardProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rewards',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Display the total count of rewards, handling pluralization.
                Text(
                    '${rewards.length} reward${rewards.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153), // ~60% opacity
                        )),
              ],
            ),
            const SizedBox(height: 16),
            // --- Content Area ---
            // Conditionally display the list or an empty state indicator.
            rewards.isEmpty
                ? const _EmptyRewardsIndicator()
                : Column(
                    // Map each Reward object to a RewardListItem widget.
                    children: rewards
                        .map((reward) => RewardListItem(
                              reward: reward,
                              // Pass the delete function to the list item.
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

/// A widget that represents a single item in the reward list.
///
/// It displays the details of a [Reward], including its title, description,
/// and rarity, and provides a delete button to remove it.
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
        elevation: 1, // Subtle shadow for depth.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          // A faint border to define the card's edge.
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(26), // 10%
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          // The primary title of the reward.
          title: Text(
            reward.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          // The subtitle area contains the description and rarity.
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show the description if it's not empty.
              if (reward.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    reward.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(178), // ~70%
                        ),
                  ),
                ),
              // Display the rarity of the reward.
              Text(
                'Rarity: ${reward.rarity}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(153), // ~60%
                    ),
              ),
            ],
          ),
          // A trailing delete button.
          trailing: IconButton(
            icon:
                Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            onPressed: onDelete, // Execute the callback when pressed.
          ),
        ),
      ),
    );
  }
}

/// A private helper widget displayed when the reward list is empty.
///
/// This provides a user-friendly message with an icon, improving the user
/// experience by clearly indicating the state of the list.
class _EmptyRewardsIndicator extends StatelessWidget {
  const _EmptyRewardsIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            // A relevant icon to visually represent rewards.
            Icon(Icons.card_giftcard_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(102)), // ~40%
            const SizedBox(height: 16),
            // A clear, informative text message.
            Text('No rewards created yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(153), // ~60%
                    )),
          ],
        ),
      ),
    );
  }
}