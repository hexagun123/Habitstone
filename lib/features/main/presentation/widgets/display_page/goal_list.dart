// lib/features/main/presentation/widgets/goal_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/util.dart';
import '../../../../../core/model/goal.dart';
import '../../../../../core/provider/goal.dart';

class GoalList extends ConsumerWidget {
  const GoalList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final goalNotifier = ref.read(goalProvider.notifier);

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
                  'Goals',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text('${goals.length} goal${goals.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        )),
              ],
            ),
            const SizedBox(height: 16),
            goals.isEmpty
                ? const _EmptyGoalsIndicator()
                : Column(
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

  void _showEditDialog(BuildContext context, WidgetRef ref, Goal goal) {
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedGoal = goal.copyWith(
                title: titleController.text,
                description: descriptionController.text,
              );
              ref.read(goalProvider.notifier).updateGoal(goal, updatedGoal);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

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
    final needsUpdate = lastUpdateDate.isBefore(today) || !goal.updated;

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
            goal.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (goal.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(178),
                        ),
                  ),
                ),
              Row(
                children: [
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: needsUpdate
                          ? Colors.orange.withAlpha(51)
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

class _EmptyGoalsIndicator extends StatelessWidget {
  const _EmptyGoalsIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(Icons.flag_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102)),
            const SizedBox(height: 16),
            Text('No goals created yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(153),
                    )),
            const SizedBox(height: 8),
            Text('Create your first goal to start tracking progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(102),
                    )),
          ],
        ),
      ),
    );
  }
}
