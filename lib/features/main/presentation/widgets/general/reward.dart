import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/model/reward.dart';
import '../../../../../core/provider/reward.dart';
import '../../../../../core/data/quote.dart';

class RewardPopup extends ConsumerStatefulWidget {
  const RewardPopup({super.key});

  @override
  ConsumerState<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends ConsumerState<RewardPopup> {
  Reward? _currentReward;
  int _remainingTimeInSeconds = 0;
  Timer? _timer;
  String? _quote; // State variable to hold the quote

  @override
  void initState() {
    super.initState();
    // Fetch the reward and the quote ONCE when the state is initialized.
    final reward = ref.read(rewardProvider.notifier).getRandomReward();
    _quote = ref.read(quoteProvider.notifier).getRandomQuote();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reward != null) {
        setState(() {
          _currentReward = reward;
          _remainingTimeInSeconds = reward.time * 60;
        });
        _startTimer();
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    final remainingMinutes = _remainingTimeInSeconds ~/ 60;
    final remainingSeconds = _remainingTimeInSeconds % 60;

    return AlertDialog(
      title: Text(_currentReward!.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentReward!.description),

          // Display the quote if it exists
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
        TextButton(
          onPressed: _closePopup,
          child: const Text('Quit'),
        ),
      ],
    );
  }
}

void showRewardPopup(BuildContext context, WidgetRef ref) {
  final rewards = ref.read(rewardProvider);
  if (rewards.isEmpty) {
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const RewardPopup(),
  );
}
