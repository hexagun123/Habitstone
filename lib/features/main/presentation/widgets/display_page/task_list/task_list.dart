// lib/features/main/presentation/widgets/task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/provider/task.dart';
import 'list_item.dart';
import 'empty.dart';
import 'popup.dart';
import '../../general/randomizer.dart';

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the entire task provider to react to changes
    final tasks = ref.watch(taskProvider);
    final displayedTasks = tasks.where((task) => task.display).toList();

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
                  'Tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      onPressed: () => showTaskPopup(context, ref),
                      tooltip: 'Add Random Task from Pool',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddTaskPopup(context, ref),
                      tooltip: 'Add Task from Pool',
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

  void _showAddTaskPopup(BuildContext context, WidgetRef ref) {
    final tasks = ref.read(taskProvider);
    final hiddenTasks = tasks.where((task) => !task.display).toList();
    final taskNotifier = ref.read(taskProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task from Pool'),
        content: hiddenTasks.isEmpty
            ? const Text('No hidden tasks available')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: hiddenTasks.length,
                  itemBuilder: (context, index) {
                    final task = hiddenTasks[index];
                    return NewTaskPopUp(
                      task: task,
                      onActivate: () => taskNotifier.activateTask(task),
                      onRandomize: () => taskNotifier.activateWeightedTask(),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
