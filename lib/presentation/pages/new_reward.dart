/// This file defines the UI and logic for the "Add Reward" page. It allows users
/// to create new rewards with details such as title, description, rarity, and a
/// specific time duration for the reward.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/model/reward.dart';
import '../../core/provider/rewards.dart';

import 'package:showcaseview/showcaseview.dart';
import '../../../../../core/data/showcase_key.dart';

/// The main page widget for adding a new reward.
/// It sets up the Scaffold, AppBar, and contains the [RewardForm].
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

/// A stateful widget that contains the form for creating a new reward.
class RewardForm extends ConsumerStatefulWidget {
  const RewardForm({super.key});

  @override
  ConsumerState<RewardForm> createState() => _AddRewardFormState();
}

/// The state associated with [RewardForm].
/// It manages the form's state, including text controllers, slider values,
/// validation, and the submission process.
class _AddRewardFormState extends ConsumerState<RewardForm> {
  // A global key to uniquely identify the Form and allow for validation.
  final _formKey = GlobalKey<FormState>();
  // Controllers for the text input fields.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // State variables for form input values.
  double _rarityValue = 1.0;
  double _timeValue = 30.0;
  bool _isSubmitting =
      false; // To disable buttons and show a loading indicator.

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed to prevent memory leaks.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handles the reward creation logic.
  /// This method validates the form, creates a new [Reward] object,
  /// calls the provider to save it, shows user feedback, and handles errors.
  Future<void> _createReward() async {
    // Return early if the form is not valid.
    if (!_formKey.currentState!.validate()) return;

    // Unfocus any active text fields to dismiss the keyboard.
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final newReward = Reward(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        rarity: _rarityValue.toInt(),
        time: _timeValue.toInt(), // Assign time from the state variable.
      );

      // Call the provider's method to create and save the new reward.
      await ref.read(rewardProvider.notifier).createReward(newReward);

      if (mounted) {
        // Show a success message.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward added successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to the previous screen.
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        // Show an error message if creation fails.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Ensure the submitting state is reset, even if an error occurred.
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                  // Form header.
                  Text(
                    'Reward Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Reward Title field.
                  Showcase(
                    key: sixteen,
                    title: title_sixteen,
                    description: description_sixteen,
                    child: TextFormField(
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
                  ),
                  const SizedBox(height: 16),
                  // Reward Description field.
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

                  // Rarity Slider Section.
                  Showcase(
                    key: seventeen,
                    title: title_seventeen,
                    description:
                        description_seventeen,
                    child: Column(children: [
                      Text(
                        'Rarity: ${_rarityValue.toInt()}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: _rarityValue,
                        min: 1,
                        max: 10,
                        divisions: 9, // Allows for integer steps from 1 to 10.
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
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Time Slider Section.
                  Showcase(
                    key: eighteen,
                    title: title_eighteen,
                    description:
                        description_eighteen,
                    child: Text(
                      'Time: ${_timeValue.toInt()} minutes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Slider(
                    value: _timeValue,
                    min: 0,
                    max: 180, // Maximum duration of 3 hours.
                    divisions: 36, // Snaps every 5 minutes.
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
                  // Form Action Buttons.
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
                                // Show a loading indicator during submission.
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
          // Informational text at the bottom of the page.
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Rewards are items you can earn by completing tasks. Rarity determines how often a reward might be chosen.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
