/// This file defines the EmptyTasksIndicator widget, which provides a
/// user-friendly message and a call-to-action when the main task list is empty.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget displayed when there are no active tasks to show.
///
/// It presents an icon, an informational message, and a button that navigates
/// the user to the screen for creating a new task.
class EmptyTasksIndicator extends StatelessWidget {
  /// Creates an EmptyTasksIndicator widget.
  const EmptyTasksIndicator({super.key});

  /// Describes the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // Add vertical padding for spacing.
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            // Display a checklist icon to visually represent tasks.
            Icon(
              Icons.checklist,
              size: 48,
              // Use a semi-transparent color for the icon.
              color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
            ),
            const SizedBox(height: 16),
            // Informational text for the user.
            Text(
              'No tasks created yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
            ),
            const SizedBox(height: 8),
            // A button to prompt the user to create a task.
            TextButton(
              onPressed: () {
                // Use go_router to navigate to the new task creation page.
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