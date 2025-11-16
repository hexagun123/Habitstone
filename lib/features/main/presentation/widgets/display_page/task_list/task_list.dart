/// This file defines the TaskList widget, which is a central UI component
/// for displaying the list of currently active tasks. It allows users to
/// add new tasks either randomly or by direct selection from a hidden pool.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/provider/task.dart';
import 'list_item.dart';
import 'empty.dart';
import 'popup.dart';
import '../../general/randomizer.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../../../core/data/showcase_key.dart';

/// A widget that displays the list of tasks marked for display.
///
/// This `ConsumerWidget` listens to the `taskProvider` and rebuilds whenever
/// the task list changes. It provides UI for adding new tasks and shows an
/// empty state indicator when no tasks are active.
class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the task provider to get the current list of all tasks.
    final tasks = ref.watch(taskProvider);
    // Filter the list to include only tasks that should be displayed.
    final displayedTasks = tasks.where((task) => task.display).toList();

    // The main container for the task list UI.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row containing the title and action buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Section title.
                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Row for action icons and task count.
                Row(
                  children: [
                    // Showcase widget for the "Random Task" feature tour.
                    Showcase(
                      key: twentyFour,
                      title: title_twentyFour,
                      description:
                          description_twentyFour,
                      // Button to trigger the random task generation popup.
                      child: IconButton(
                        icon: const Icon(Icons.shuffle),
                        onPressed: () => showTaskPopup(context, ref),
                        tooltip: 'Add Random Task from Pool',
                      ),
                    ),
                    // Showcase widget for the "Add Task" feature tour.
                    Showcase(
                      key: twentyFive,
                      title: title_twentyFive,
                      description:
                          description_twentyFive,
                      // Button to show the popup for adding a task directly.
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddTaskPopup(context, ref),
                        tooltip: 'Add Task from Pool',
                      ),
                    ),
                    // Displays the current number of active tasks.
                    Text(
                      '${displayedTasks.length} tasks',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            // Apply partial transparency to the text color.
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(153),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Conditionally display either the list of tasks or an empty state indicator.
            displayedTasks.isEmpty
                ? const EmptyTasksIndicator()
                : Column(
                    children: displayedTasks
                        .map((task) => TaskListItem(task: task))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog listing all hidden (inactive) tasks, allowing the user
  /// to select one to add to the active task list.
  ///
  /// This function reads the current task list, filters out the tasks that are not
  /// currently displayed, and presents them in a `ListView` within an `AlertDialog`.
  /// If no hidden tasks are available, it shows a corresponding message.
  void _showAddTaskPopup(BuildContext context, WidgetRef ref) {
    // Read the task provider once without listening for changes.
    final tasks = ref.read(taskProvider);
    // Filter for tasks that are not currently displayed.
    final hiddenTasks = tasks.where((task) => !task.display).toList();
    // Get the notifier to call methods for state changes.
    final taskNotifier = ref.read(taskProvider.notifier);

    showDialog(
        context: context,
        builder: (context) {
          Widget dialogContent;

          // Check if there are any hidden tasks to display.
          if (hiddenTasks.isEmpty) {
            dialogContent = const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text('No hidden tasks available'),
              ),
            );
          } else {
            // Display hidden tasks in a scrollable list.
            dialogContent = SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: hiddenTasks.length,
                itemBuilder: (context, index) {
                  final task = hiddenTasks[index];
                  // Use a custom popup widget for each task item.
                  return NewTaskPopUp(
                    task: task,
                    onActivate: () => taskNotifier.activateTask(task),
                    onRandomize: () => taskNotifier.activateWeightedTask(),
                  );
                },
              ),
            );
          }

          // The main dialog window.
          return AlertDialog(
            title: const Text('Add Task from Pool'),
            content: dialogContent,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        });
  }
}