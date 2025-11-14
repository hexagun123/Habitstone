import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/model/task.dart';
import '../../../../../../core/data/quote.dart';

class NewTaskPopUp extends ConsumerWidget {
  final Task task;
  final VoidCallback onActivate;
  final VoidCallback onRandomize;

  const NewTaskPopUp({
    super.key,
    required this.task,
    required this.onActivate,
    required this.onRandomize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty) Text(task.description),
                const SizedBox(height: 4),
                Text(
                  '${task.appearanceCount} appearances left',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            onTap: () {
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
