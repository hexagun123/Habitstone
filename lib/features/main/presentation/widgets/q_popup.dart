import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/data/quote.dart';
/// Shows a dialog with a random quote.
Future<void> showRandomQuotePopup(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return const RandomQuotePopup();
    },
  );
}

class RandomQuotePopup extends ConsumerWidget {
  const RandomQuotePopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qProvider = ref.watch(quoteProvider);

    return AlertDialog(
      title: const Text('A Quote For You'),
      content: qProvider.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Text(
          'Failed to load quotes: $error',
          style: const TextStyle(color: Colors.red),
        ),
        data: (quotes) {
          final randomQuote =
              ref.read(quoteProvider.notifier).getRandomQuote();
          return Text(
            randomQuote ?? 'No quotes found.',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}