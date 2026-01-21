/// This file defines the TaskListItem widget, which represents a single, active task
/// in the main task list. It's an expandable tile that shows task details,
/// linked goals, and provides actions like marking as done or deleting.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../core/provider/task.dart';
import '../../../../core/provider/goals.dart';
import '../../../../../../../core/model/task.dart';
import '../../general/reward.dart';

/// A widget that displays an individual task with expandable details.
///
/// This `ConsumerWidget` shows primary task information in a collapsed state.
/// When expanded, it reveals associated goals and action buttons for completing
/// or deleting the task.
class TaskListItem extends ConsumerWidget {
  /// The task data to be displayed by this widget.
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the goal provider to get the list of all goals.
    // This is used to display the title of goals linked to this task.
    final goals = ref.watch(goalProvider);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      // Custom shape and border for the card.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          // Subtle border color with low alpha.
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      // An expandable list tile.
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        // The primary title of the task.
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        // The subtitle section for additional, brief information.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditionally display the description if it exists.
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1, // Prevent long descriptions from wrapping.
                overflow: TextOverflow.ellipsis, // Add '...' for overflow.
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(178), // Slightly transparent text.
                    ),
              ),
            const SizedBox(height: 4),
            // Display the remaining appearance count for the task.
            Text(
              '${task.appearanceCount} appearances left',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
            ),
          ],
        ),
        // Content shown when the tile is expanded.
        children: [
          // Section for displaying goals linked to this task.
          if (task.goalIds.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              // Wrap allows chips to flow to the next line if space is limited.
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: task.goalIds.map((goalId) {
                  // Find the goal object corresponding to the goalId.
                  final goal = goals.firstWhere(
                    (g) => g.id == goalId,
                  );
                  // Display each linked goal as a Chip.
                  return Chip(
                    label: Text(
                      goal.title,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
            ),

          // Action buttons for the task.
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons right.
              children: [
                // Delete button.
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      ref.read(taskProvider.notifier).deleteTask(task),
                  tooltip: 'Delete Task',
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                // Mark as Done button.
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Mark Done'),
                  onPressed: () => {
                    // Call the notifier to update the task's state.
                    ref.read(taskProvider.notifier).markTaskDone(task),
                    // Show a confirmation SnackBar.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task Done!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    ),
                    // Show the reward popup upon task completion.
                    showRewardPopup(context, ref),
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
