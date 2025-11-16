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

  /// The callback function for a randomization action. Note: This is passed
  /// but not used in the current UI of this specific widget.
  final VoidCallback onRandomize;

  const NewTaskPopUp({
    super.key,
    required this.task,
    required this.onActivate,
    required this.onRandomize,
  });

  /// Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          // A standard list item layout for displaying task information.
          ListTile(
            // The main title of the task.
            title: Text(task.title),
            // Subtitle area for additional details like description and appearance count.
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
            // Defines the action to perform when the list tile is tapped.
            onTap: () {
              // Execute the provided activation callback.
              onActivate();
              // Close the dialog.
              Navigator.pop(context);
              // Show a confirmation message to the user.
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
