// features/main/presentation/widgets/general/reward.dart
// everything about reward and the popup

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/data/quote.dart';
import '../../../../../../core/model/reward.dart';
import '../../../core/provider/rewards.dart';

void showRewardPopup(BuildContext context, WidgetRef ref) {

  // get some states and do some safety checks
  final rewards = ref.read(rewardProvider);
  if (rewards.isEmpty) {
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false, // you can not just go back to the main program without dealing with me
    builder: (context) => const RewardPopup(),
  );
}

/// reward popup main body
class RewardPopup extends ConsumerStatefulWidget {
  const RewardPopup({super.key});

  @override
  ConsumerState<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends ConsumerState<RewardPopup> {
  Reward? _currentReward; 
  int _remainingTimeInSeconds = 0; // countdown
  Timer? _timer;
  String? _quote;

  @override
  void initState() {
    super.initState();

    // grabing some states
    final reward = ref.read(rewardProvider.notifier).getRandomReward();
    _quote = ref.read(quoteProvider.notifier).getRandomQuote();

    WidgetsBinding.instance.addPostFrameCallback((_) { // another safety check just in case
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


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // periodic refresh
      if (_remainingTimeInSeconds > 0) {
        // trigger rebuild
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
        // Time's up!
        _closePopup();
      }
    });
  }

  void _closePopup() {
    _timer?.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// ensure no memory leaks
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // loading
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

    /// Calculate minutes and seconds for display.
    final remainingMinutes = _remainingTimeInSeconds ~/ 60;
    final remainingSeconds = _remainingTimeInSeconds % 60;

    return AlertDialog(
      title: Text(_currentReward!.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentReward!.description),

          if (_quote != null) ...[
            const SizedBox(height: 16),
            Text(
              '"$_quote"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],

          const SizedBox(height: 24),

          Center(
            child: Text(
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
