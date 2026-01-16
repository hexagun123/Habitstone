/// This file defines the NewTaskPopUp widget, a reusable UI component
/// used within dialogs to represent a single, selectable task from the hidden pool.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/model/task.dart';

/// A widget that displays details of a single task in a list format,
/// typically within a popup or dialog.
///
/// It shows the task's title, description (if available), and the remaining
/// number of times it can appear. Tapping the widget triggers a callback
/// to activate the task.
class NewTaskPopUp extends ConsumerWidget {
  /// The task object containing the data to be displayed.
  final Task task;

  /// The callback function to be executed when the user taps on this widget
  /// to activate the task.
  final VoidCallback onActivate;


  const NewTaskPopUp({
    super.key,
    required this.task,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          // A list layout
          ListTile(
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Conditionally display the description only if it's not empty.
                if (task.description.isNotEmpty) Text(task.description),
                const SizedBox(height: 4),
                // Display how many more times the task can be assigned.
                Text(
                  '${task.appearanceCount} appearances left',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              // Execute callback
              onActivate();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "${task.title}" to tasks'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
