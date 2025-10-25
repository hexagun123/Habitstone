// lib/features/main/presentation/widgets/task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/provider/task.dart';
import '../../../../../core/provider/goal.dart';
import '../../../../../core/model/task.dart';
import '../general/reward.dart';

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
                ? const _EmptyTasksIndicator()
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
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty)
                              Text(task.description),
                            const SizedBox(height: 4),
                            Text(
                              '${task.appearanceCount} appearances left',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        onTap: () {
                          taskNotifier.activateTask(task);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${task.title}" to tasks'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
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

class TaskListItem extends ConsumerWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(178),
                    ),
              ),
            const SizedBox(height: 4),
            Text(
              '${task.appearanceCount} appearances left',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
            ),
          ],
        ),
        children: [
          // Linked goals section
          if (task.goalIds.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: task.goalIds.map((goalId) {
                  final goal = goals.firstWhere(
                    (g) => g.key == goalId,
                  );

                  return Chip(
                    label: Text(goal.title),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
            ),

          // Action buttons
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      ref.read(taskProvider.notifier).deleteTask(task),
                  tooltip: 'Delete Task',
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Mark Done'),
                  onPressed: () => {
                    ref.read(taskProvider.notifier).markTaskDone(task, ref),
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task Done!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    ),
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

  void _showEditDialog(BuildContext context, WidgetRef ref, Task task) {
    // Implement your edit dialog here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: const Text('Task editing'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksIndicator extends StatelessWidget {
  const _EmptyTasksIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(
              Icons.checklist,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks created yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.push('/new-task');
              },
              child: const Text('Create your first task'),
            ),
          ],
        ),
      ),
    );
  }
}
