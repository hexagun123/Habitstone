// lib/features/main/presentation/widgets/goal_list.dart
// This file contains the UI components for displaying, editing, and deleting
// the user's goals. It includes the main list container, individual goal
// items with status indicators, and a placeholder for when no goals exist.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/data/util.dart';
import '../../../../../../core/model/goal.dart';
import '../../../core/provider/goals.dart';

/// A widget that displays the complete list of user-defined goals.
///
/// This [ConsumerWidget] subscribes to the `goalProvider` to display an
/// up-to-date list of goals. It handles rendering the list, showing an
/// empty state indicator, and launching the edit dialog for a specific goal.
class GoalList extends ConsumerWidget {
  const GoalList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to rebuild the list when goals are added, updated, or removed.
    final goals = ref.watch(goalProvider);
    // Read the notifier to access methods for deleting or updating goals.
    final goalNotifier = ref.read(goalProvider.notifier);

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
                  'Goals',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Display the total count of goals, handling pluralization.
                Text('${goals.length} goal${goals.length != 1 ? 's' : ''}',
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
            goals.isEmpty
                ? const _EmptyGoalsIndicator()
                : Column(
                    // Map each Goal object to a GoalListItem widget.
                    children: goals
                        .map((goal) => GoalListItem(
                              goal: goal,
                              onEdit: () => _showEditDialog(context, ref, goal),
                              onDelete: () => goalNotifier.deleteGoal(goal),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog for editing a goal's title and description.
  ///
  /// This private method is called when the user taps the edit icon on a
  /// [GoalListItem]. It pre-populates the text fields with the existing goal
  /// data and provides "Save" and "Cancel" actions.
  void _showEditDialog(BuildContext context, WidgetRef ref, Goal goal) {
    // Controllers to manage the state of the text fields.
    final titleController = TextEditingController(text: goal.title);
    final descriptionController = TextEditingController(text: goal.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          // Cancel button closes the dialog.
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Save button updates the goal and closes the dialog.
          FilledButton(
            onPressed: () {
              // Create a new goal object with the updated details.
              final updatedGoal = goal.copyWith(
                title: titleController.text,
                description: descriptionController.text,
              );
              // Call the provider's update method.
              ref.read(goalProvider.notifier).updateGoal(updatedGoal);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// A widget representing a single item in the goal list.
///
/// It displays the goal's details, including title, description, streak, and
/// completion status for the day. It also provides edit and delete actions.
class GoalListItem extends ConsumerWidget {
  final Goal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalListItem({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateUtil.now();
    final lastUpdateDate = goal.lastUpdate;
    // Determine if the goal needs an update for the current day.
    final needsUpdate = lastUpdateDate.isBefore(today) || !goal.updated;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 1, // Subtle shadow for depth.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(26), // ~10%
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          // The main title of the goal.
          title: Text(
            goal.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          // Subtitle section for detailed information.
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only display the description if it is not empty.
              if (goal.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(178), // ~70%
                        ),
                  ),
                ),
              Row(
                children: [
                  // Streak icon and text, colored based on streak value.
                  Icon(Icons.local_fire_department,
                      size: 16,
                      color: goal.streak > 0 ? Colors.orange : Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${goal.streak} day${goal.streak == 1 ? '' : 's'} streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: goal.streak > 0 ? Colors.orange : Colors.grey,
                        ),
                  ),
                  const SizedBox(width: 12),
                  // Status tag indicating if the goal needs an update today.
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: needsUpdate
                          ? Colors.orange.withAlpha(51) // ~20%
                          : Colors.green.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      needsUpdate ? 'Needs update' : 'Completed today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: needsUpdate ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Trailing action buttons for editing and deleting.
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A private helper widget displayed when the goal list is empty.
///
/// This provides a user-friendly message with an icon and a call to action,
/// improving the onboarding experience.
class _EmptyGoalsIndicator extends StatelessWidget {
  const _EmptyGoalsIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            // A relevant icon to visually represent goals.
            Icon(Icons.flag_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(102)), // ~40%
            const SizedBox(height: 16),
            // The main message.
            Text('No goals created yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(153), // ~60%
                    )),
            const SizedBox(height: 8),
            // An additional instructional message.
            Text('Create your first goal to start tracking progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(102), // ~40%
                    )),
          ],
        ),
      ),
    );
  }
}
