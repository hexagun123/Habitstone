// features/main/presentation/widgets/general/randomizer.dart
// pop up for random task

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/quote.dart';
import '../../../../../core/provider/task.dart';

class TaskPopup extends ConsumerWidget {
  const TaskPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // get some states
    final taskNotifier = ref.read(taskProvider.notifier);
    final qQuote = ref.watch(quoteProvider);

    return AlertDialog(
      title: const Text('Get Random Task'),

      /// async handling
      content: qQuote.when(
        loading: () => const Text('Loading inspirational quote...'),
        error: (err, stack) => const Text('Could not load quote.'),
        data: (quotes) {
          // display the quote
          final randomQuote = ref.read(quoteProvider.notifier).getRandomQuote();
          return Text(
              randomQuote ?? 'No quote available.'); // fall back
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await taskNotifier.activateRandomTask(); // activate a random task on press

            if (success) {
              Navigator.pop(context); //leave
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
  showDialog( // showing the popup, similar to a constructor
    context: context,
    builder: (context) => const TaskPopup(),
  );
}