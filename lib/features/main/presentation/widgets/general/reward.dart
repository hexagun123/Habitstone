// features/main/presentation/widgets/general/reward.dart
// This file defines the functionality for displaying a timed reward pop-up.
// When triggered, it selects a random reward and quote, and presents them
// in a non-dismissible dialog with a countdown timer.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/quote.dart';
import '../../../../../core/model/reward.dart';
import '../../../../../core/provider/reward.dart';

/// A public function to trigger the display of the reward dialog.
///
/// It first checks if any rewards exist. If so, it displays the [RewardPopup]
/// dialog. The dialog is set to be non-dismissible by the user tapping outside
/// of it (`barrierDismissible: false`) to ensure the timed reward period is observed.
void showRewardPopup(BuildContext context, WidgetRef ref) {
  // Read the provider once to check for the existence of rewards.
  final rewards = ref.read(rewardProvider);
  if (rewards.isEmpty) {
    // Do not show the popup if there are no rewards to claim.
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false, // User must interact with the dialog.
    builder: (context) => const RewardPopup(),
  );
}

/// A stateful widget that represents the content of the reward dialog.
///
/// This widget manages its own state, including the currently displayed reward,
/// a countdown timer, and a randomly selected quote.
class RewardPopup extends ConsumerStatefulWidget {
  const RewardPopup({super.key});

  @override
  ConsumerState<RewardPopup> createState() => _RewardPopupState();
}

/// The state management logic for the [RewardPopup] widget.
class _RewardPopupState extends ConsumerState<RewardPopup> {
  Reward? _currentReward; // The reward being displayed.
  int _remainingTimeInSeconds = 0; // The countdown timer's current value.
  Timer? _timer; // The periodic timer instance.
  String? _quote; // A motivational quote to display.

  @override
  void initState() {
    super.initState();
    // Fetch the necessary data once using `ref.read` as it's a one-time setup action.
    final reward = ref.read(rewardProvider.notifier).getRandomReward();
    _quote = ref.read(quoteProvider.notifier).getRandomQuote();

    // Safely update state and start the timer after the first frame is built.
    // This prevents errors from calling Navigator or setState during the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reward != null) {
        setState(() {
          _currentReward = reward;
          _remainingTimeInSeconds =
              reward.time * 60; // Convert minutes to seconds.
        });
        _startTimer();
      } else {
        // If no reward could be found, close the (potentially empty) dialog.
        Navigator.of(context).pop();
      }
    });
  }

  /// Sets up and starts the periodic countdown timer.
  ///
  /// The timer ticks every second, updating the state to reflect the new
  /// remaining time. When the timer reaches zero, it triggers the popup to close.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        // Trigger a rebuild to show the updated time.
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
        // Time is up, close the dialog.
        _closePopup();
      }
    });
  }

  /// Safely cancels the timer and closes the dialog.
  ///
  /// It checks if the widget is still in the widget tree (`mounted`) before
  /// attempting to use the Navigator to prevent errors.
  void _closePopup() {
    _timer?.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Cleans up resources when the widget is removed from the widget tree.
  ///
  /// This is a critical lifecycle method that prevents memory leaks by ensuring
  /// the `Timer` is cancelled and does not continue to run in the background.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // While the reward is being fetched, display a loading indicator.
    if (_currentReward == null) {
      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Claiming your reward..."),
          ],
        ),
      );
    }

    // Calculate minutes and seconds for display.
    final remainingMinutes = _remainingTimeInSeconds ~/ 60;
    final remainingSeconds = _remainingTimeInSeconds % 60;

    // The main dialog UI.
    return AlertDialog(
      title: Text(_currentReward!.title),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Keep the dialog compact.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentReward!.description),

          // Conditionally display the quote if one was successfully fetched.
          if (_quote != null) ...[
            const SizedBox(height: 16),
            Text(
              '"$_quote"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],

          const SizedBox(height: 24),

          // The centered countdown timer display.
          Center(
            child: Text(
              // Format the time string, e.g., "5:03".
              'Time remaining: $remainingMinutes:${remainingSeconds.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
      actions: [
        // Button to allow the user to close the reward timer early.
        TextButton(
          onPressed: _closePopup,
          child: const Text('Quit'),
        ),
      ],
    );
  }
}
