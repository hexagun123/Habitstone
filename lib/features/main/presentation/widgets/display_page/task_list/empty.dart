import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyTasksIndicator extends StatelessWidget {
  const EmptyTasksIndicator();

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