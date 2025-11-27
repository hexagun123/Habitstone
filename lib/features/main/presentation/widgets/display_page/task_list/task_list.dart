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
import 'dart:developer' as developer; // Import for logging

/// A widget that displays the list of tasks marked for display.
class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the task provider to get the current list of all tasks.
    final tasks = ref.watch(taskProvider);

    // Filter: Tasks currently visible to the user
    final displayedTasks = tasks.where((task) => task.display).toList();

    // Filter: Tasks in the "Pool" (Hidden) that can be shuffled/added
    final hiddenTasks = tasks.where((task) => !task.display).toList();

    // LOG: Debug current state
    print(
        "DEBUG: TaskList Build - Total: ${tasks.length} | Displayed: ${displayedTasks.length} | Hidden: ${hiddenTasks.length}");

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
                    // --- SHUFFLE BUTTON (Random Task) ---
                    Showcase(
                      key: twentyFour,
                      title: title_twentyFour,
                      description: description_twentyFour,
                      child: IconButton(
                        icon: const Icon(Icons.shuffle),
                        tooltip: 'Add Random Task from Pool',
                        onPressed: hiddenTasks.isEmpty
                            ? () {
                                print(
                                    "DEBUG: Shuffle clicked, but hiddenTasks is empty.");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'No tasks in the pool to shuffle!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            : () {
                                print(
                                    "DEBUG: Shuffle clicked. Opening showTaskPopup.");
                                try {
                                  showTaskPopup(context, ref);
                                } catch (e, stack) {
                                  print(
                                      "DEBUG: Error opening showTaskPopup: $e");
                                  print(stack);
                                }
                              },
                      ),
                    ),

                    // --- ADD BUTTON (Manual Selection) ---
                    Showcase(
                      key: twentyFive,
                      title: title_twentyFive,
                      description: description_twentyFive,
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          print(
                              "DEBUG: Add button clicked. Opening selection dialog.");
                          _showAddTaskPopup(context, ref);
                        },
                        tooltip: 'Add Task from Pool',
                      ),
                    ),

                    // Displays the current number of active tasks.
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

  /// Displays a dialog listing all hidden (inactive) tasks.
  void _showAddTaskPopup(BuildContext context, WidgetRef ref) {
    // Read the task provider state at the moment the dialog is opened.
    final tasks = ref.read(taskProvider);
    final hiddenTasks = tasks.where((task) => !task.display).toList();
    final taskNotifier = ref.read(taskProvider.notifier);

    print(
        "DEBUG: _showAddTaskPopup opened. Available hidden tasks: ${hiddenTasks.length}");

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
                  return NewTaskPopUp(
                    key: ValueKey(task.id),
                    task: task,
                    onActivate: () {
                      print(
                          "DEBUG: Activating specific task: ${task.title} (${task.id})");
                      taskNotifier.activateTask(task);
                    },
                    // CRITICAL FIX: Made async to handle Future errors properly
                    onRandomize: () async {
                      print("DEBUG: Randomize clicked inside Add Task Popup.");

                      // 1. Refresh state to ensure we aren't using stale data
                      final currentTasks = ref.read(taskProvider);
                      final currentPool =
                          currentTasks.where((t) => !t.display).toList();

                      print(
                          "DEBUG: Current fresh pool size: ${currentPool.length}");

                      if (currentPool.isNotEmpty) {
                        try {
                          // 2. Await the function so try/catch can actually catch the error
                          print("DEBUG: Calling activateWeightedTask()...");
                          await taskNotifier.activateWeightedTask();

                          print(
                              "DEBUG: Randomization successful. Closing dialog.");
                          if (context.mounted) Navigator.pop(context);
                        } catch (e, stack) {
                          // 3. Catch 'Bad state' or other errors
                          print("DEBUG: ERROR in onRandomize: $e");
                          print("DEBUG: Stack Trace:\n$stack");

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error generating task: $e"),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      } else {
                        print("DEBUG: Pool is empty, cannot randomize.");
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("No tasks available to randomize.")),
                          );
                        }
                      }
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
