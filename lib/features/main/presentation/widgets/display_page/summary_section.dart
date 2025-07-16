import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/provider/task.dart';
import 'stat_card.dart';

class SummarySection extends ConsumerWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.length - completedTasks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? Row(
                        children: [
                          StatCard(
                            title: 'Total Tasks',
                            value: tasks.length.toString(),
                            icon: Icons.task_alt,
                          ),
                          const SizedBox(width: 16),
                          StatCard(
                            title: 'Completed',
                            value: completedTasks.toString(),
                            icon: Icons.check_circle,
                          ),
                          const SizedBox(width: 16),
                          StatCard(
                            title: 'Pending',
                            value: pendingTasks.toString(),
                            icon: Icons.pending,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          StatCard(
                            title: 'Total Tasks',
                            value: tasks.length.toString(),
                            icon: Icons.task_alt,
                          ),
                          const SizedBox(height: 16),
                          StatCard(
                            title: 'Completed',
                            value: completedTasks.toString(),
                            icon: Icons.check_circle,
                          ),
                          const SizedBox(height: 16),
                          StatCard(
                            title: 'Pending',
                            value: pendingTasks.toString(),
                            icon: Icons.pending,
                          ),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
