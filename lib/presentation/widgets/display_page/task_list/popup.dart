// Just a popup for the task list
// secondary widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../core/model/task.dart';

class NewTaskPopUp extends ConsumerWidget {
  final Task task;

  /// The callback function to activate the task
  /// just having it here in case the function changes
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
