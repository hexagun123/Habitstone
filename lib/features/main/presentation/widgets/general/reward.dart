import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/model/reward.dart';
import '../../../../../core/provider/reward.dart';
import 'dart:async';

class RewardPopup extends ConsumerStatefulWidget {
  const RewardPopup({super.key});

  @override
  ConsumerState<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends ConsumerState<RewardPopup> {
  Reward? _currentReward;
  int _remainingTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _showRandomReward();
  }

  void _showRandomReward() {
    final reward = ref.read(rewardProvider.notifier).getRandomReward();
    if (reward != null) {
      setState(() {
        _currentReward = reward;
        _remainingTime = reward.time;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _closePopup();
        }
      });
    });
  }

  void _closePopup() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentReward == null) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: Text(_currentReward!.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentReward!.description),
          const SizedBox(height: 16),
          Text('Time remaining: $_remainingTime seconds'),
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

void showRewardPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // User must tap button to close
    builder: (context) => const RewardPopup(),
  );
}
