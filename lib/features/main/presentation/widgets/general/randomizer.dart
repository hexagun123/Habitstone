// features/main/presentation/widgets/task_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/provider/task.dart';
import '../../../../../core/data/quote.dart';

class TaskPopup extends ConsumerWidget {
  const TaskPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(taskProvider.notifier);
    final qQuote = ref.watch(quoteProvider);

    return AlertDialog(
      title: const Text('Get Random Task'),
      content: qQuote.when(
        // UI to show while quotes are loading
        loading: () => const Text('Loading inspirational quote...'),

        // UI to show if loading failed
        error: (err, stack) => const Text('Could not load quote.'),

        // UI to show when quotes are successfully loaded
        data: (quotes) {
          final randomQuote = ref.read(quoteProvider.notifier).getRandomQuote();
          return Text(
              randomQuote ?? 'No quote available.');
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await taskNotifier.activateWeightedTask();
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
