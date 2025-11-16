// features/main/presentation/widgets/task_popup.dart
// This file defines the dialog box that allows users to request a new,
// randomly selected task. It also serves to provide a small piece of
// motivation by displaying a random quote.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/quote.dart';
import '../../../../../core/provider/task.dart';

/// A dialog widget for fetching a new random task.
///
/// This [ConsumerWidget] provides an interface for the user to trigger the
/// weighted task selection algorithm. It displays a random quote to offer
/// encouragement and contains actions to either accept a new task or cancel
/// the operation.
class TaskPopup extends ConsumerWidget {
  const TaskPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the notifier once; we only need to call its methods, not rebuild on state changes.
    final taskNotifier = ref.read(taskProvider.notifier);
    // Watch the quote provider to reactively handle its loading, error, and data states.
    final qQuote = ref.watch(quoteProvider);

    return AlertDialog(
      title: const Text('Get Random Task'),
      // Use `when` to gracefully handle the asynchronous states of the quote provider.
      // This ensures a good user experience by showing appropriate UI for each state.
      content: qQuote.when(
        loading: () => const Text('Loading inspirational quote...'),
        error: (err, stack) => const Text('Could not load quote.'),
        data: (quotes) {
          // When data is available, get a random quote to display.
          final randomQuote = ref.read(quoteProvider.notifier).getRandomQuote();
          return Text(
              randomQuote ?? 'No quote available.'); // Use fallback text if no quote.
        },
      ),
      actions: [
        // A simple button to close the dialog without taking any action.
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        // The primary action button to fetch and activate a new task.
        ElevatedButton(
          onPressed: () async {
            // Call the weighted task activation method from the task notifier.
            final success = await taskNotifier.activateWeightedTask();

            // Check if a task was successfully activated.
            if (success) {
              Navigator.pop(context); // If successful, close the dialog.
            } else {
              // If no tasks were available, inform the user with a SnackBar.
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

/// A public function to trigger the display of the task selection dialog.
///
/// This convenience function encapsulates the call to `showDialog`, making it
/// easy to invoke the [TaskPopup] from anywhere in the app that has access to
/// the build context and a widget reference.
void showTaskPopup(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => const TaskPopup(),
  );
}