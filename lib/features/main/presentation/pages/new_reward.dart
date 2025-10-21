import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/model/reward.dart';
import '../../../../core/provider/reward.dart';

class RewardPage extends ConsumerWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Reward'),
        ),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: RewardForm(),
          ),
        ));
  }
}

class RewardForm extends ConsumerStatefulWidget {
  const RewardForm({super.key});

  @override
  ConsumerState<RewardForm> createState() => _AddRewardFormState();
}

class _AddRewardFormState extends ConsumerState<RewardForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _rarityValue = 1.0;
  double _timeValue = 30.0; // State for the time slider
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createReward() async {
    if (!_formKey.currentState!.validate()) return;

    // Unfocus keyboard first
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final newReward = Reward(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        rarity: _rarityValue.toInt(),
        time: _timeValue.toInt(), // Use the new field
      );

      await ref.read(rewardProvider.notifier).createReward(newReward);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward added successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _testRandomReward() {
    final randomReward = ref.read(rewardProvider.notifier).getRandomReward();
    if (randomReward != null) {
      print('--- 🎲 Random Reward Drawn 🎲 ---');
      print('Title: ${randomReward.title}');
      print('Rarity: ${randomReward.rarity}');
      print('Time: ${randomReward.time} mins'); // Updated print
      print('---------------------------------');
    } else {
      print('--- No rewards available to draw from. ---');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          randomReward != null
              ? 'Drawn: ${randomReward.title} (Rarity: ${randomReward.rarity})'
              : 'No rewards available!',
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reward Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Reward Title',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Watch a Movie',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reward title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Describe this reward...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // --- Rarity Slider ---
                  Text(
                    'Rarity: ${_rarityValue.toInt()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _rarityValue,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _rarityValue.toInt().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _rarityValue = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'A lower number is more common. A higher number is rarer.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Time Slider ---
                  Text(
                    'Time: ${_timeValue.toInt()} minutes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _timeValue,
                    min: 0,
                    max: 180, // 3 hours
                    divisions: 36, // Snap every 5 minutes
                    label: '${_timeValue.toInt()} min',
                    onChanged: (double value) {
                      setState(() {
                        _timeValue = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'The time duration for the reward. Set to 0 for no timer.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _createReward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Add Reward'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Rewards are items you can earn by completing tasks. Rarity determines how often a reward might be chosen.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _testRandomReward,
              icon: const Icon(Icons.science),
              label: const Text('Test Random Reward Generation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
