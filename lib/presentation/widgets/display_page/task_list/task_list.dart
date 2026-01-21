// Task list UI
// Everything visual about the task system in a list format

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../core/provider/task.dart';
import 'list_item.dart';
import 'empty.dart';
import 'popup.dart';
import '../../general/randomizer.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../../../../core/data/showcase_key.dart';


class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // get the states of tasks
    final tasks = ref.watch(taskProvider);

    // visible tasks
    final displayedTasks = tasks.where((task) => task.display).toList();

    // not visible ones
    final hiddenTasks = tasks.where((task) => !task.display).toList();


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
                    Showcase( // random task
                      key: twentyFour,
                      title: title_twentyFour,
                      description: description_twentyFour,
                      child: IconButton(
                        icon: const Icon(Icons.shuffle),
                        tooltip: 'Add Random Task from Pool',
                        onPressed: hiddenTasks.isEmpty
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'No tasks in the pool to shuffle!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            : () {
                                try {
                                  showTaskPopup(context, ref);
                                } catch (e) {
                                  print(
                                      "DEBUG: Error opening showTaskPopup: $e");
                                }
                              },
                      ),
                    ),

                    Showcase( // selective task
                      key: twentyFive,
                      title: title_twentyFive,
                      description: description_twentyFive,
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _showAddTaskPopup(context, ref);
                        },
                        tooltip: 'Add Task from Pool',
                      ),
                    ),

                    Text(
                      '${displayedTasks.length} tasks',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        .map((task) => TaskListItem(
                              key: ValueKey(task.id),
                              task: task,
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog listing all hidden tasks.
  void _showAddTaskPopup(BuildContext context, WidgetRef ref) {

    // read the new states
    final tasks = ref.read(taskProvider);
    final hiddenTasks = tasks.where((task) => !task.display).toList();
    final taskNotifier = ref.read(taskProvider.notifier);

    showDialog(
        context: context,
        builder: (context) {
          Widget dialogContent;

          if (hiddenTasks.isEmpty) {
            dialogContent = const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text('No hidden tasks available'),
              ),
            );
          } else {
            dialogContent = SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: hiddenTasks.length,
                itemBuilder: (context, index) {
                  final task = hiddenTasks[index];
                  return NewTaskPopUp( // display the secondary task widget
                    key: ValueKey(task.id),
                    task: task,
                    onActivate: () {
                      taskNotifier.activateTask(task);
                    },
                  );
                },
              ),
            );
          }

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
