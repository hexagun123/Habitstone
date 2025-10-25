// features/main/presentation/widgets/task_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/provider/task.dart';

class TaskPopup extends ConsumerWidget {
  const TaskPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(taskProvider.notifier);

    return AlertDialog(
      title: const Text('Get Random Task'),
      content: const Text('Would you like to get a randomly selected task based on your preferences?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await taskNotifier.activateWeightedTask(ref);
            if (success) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No available tasks')),
              );
            }
          },
          child: const Text('Get Task'),
        ),
      ],
    );
  }
}

void showTaskPopup(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => const TaskPopup(),
  );
}