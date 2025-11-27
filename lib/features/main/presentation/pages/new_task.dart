/// This file defines the UI and logic for the "New Task" page.
/// It allows users to create tasks with details such as title, description,
/// appearance count, importance, and links to existing goals.
/// The form includes validation and state management for a seamless user experience.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:developer';

import '../../../../core/data/showcase_key.dart';
import '../../../../core/model/task.dart';
import '../../../../core/provider/goal.dart';
import '../../../../core/provider/task.dart';

/// The main page widget for creating a new task.
/// It sets up the basic layout structure with a Scaffold and AppBar.
class NewTaskPage extends ConsumerWidget {
  const NewTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: NewTaskForm(),
      ),
    );
  }
}

/// A stateful widget that encapsulates the form for creating a new task.
class NewTaskForm extends ConsumerStatefulWidget {
  const NewTaskForm({super.key});

  @override
  ConsumerState<NewTaskForm> createState() => _NewTaskFormState();
}

/// Manages the state for [NewTaskForm].
/// This includes handling form controllers, validation, user input,
/// and the task submission process.
class _NewTaskFormState extends ConsumerState<NewTaskForm> {
  // A global key to uniquely identify the Form widget and enable validation.
  final _formKey = GlobalKey<FormState>();
  // Text editing controllers for the form's input fields.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _appearanceController = TextEditingController(text: '1');

  // Tracks the form submission state to prevent multiple submissions.
  bool _isSubmitting = false;

  // Stores the database IDs of goals linked to this task.
  List<String> _selectedGoalIds = [];

  // The number of times the task should appear.
  int _appearanceCount = 1;
  // The importance rating of the task, used for prioritization.
  int _importance = 5;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the appearance text field to sync state.
    _appearanceController.addListener(_onAppearanceTextChanged);
  }

  /// Synchronizes the `_appearanceCount` state with the text field input.
  /// Parses the text, clamps the value between 1 and 100, and updates
  /// the text field if the parsed value was outside this range.
  void _onAppearanceTextChanged() {
    final text = _appearanceController.text;
    if (text.isNotEmpty) {
      final value = int.tryParse(text) ?? 1;
      final clampedValue = value.clamp(1, 100);
      if (clampedValue != _appearanceCount) {
        setState(() {
          _appearanceCount = clampedValue;
        });

        if (value != clampedValue) {
          _appearanceController.text = clampedValue.toString();
          // Move cursor to the end of the text.
          _appearanceController.selection = TextSelection.fromPosition(
            TextPosition(offset: _appearanceController.text.length),
          );
        }
      }
    }
  }

  /// Updates the `_appearanceCount` and the corresponding text field
  /// when the user interacts with the appearance slider.
  void _onAppearanceSliderChanged(double value) {
    final intValue = value.round();
    setState(() {
      _appearanceCount = intValue;
      _appearanceController.text = intValue.toString();
    });
  }

  @override
  void dispose() {
    // Dispose of controllers to free up resources and prevent memory leaks.
    _titleController.dispose();
    _descriptionController.dispose();
    _appearanceController.removeListener(_onAppearanceTextChanged);
    _appearanceController.dispose();
    super.dispose();
  }

  /// Handles the entire task creation process.
  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate())
      return; // Abort if form is not valid.

    FocusScope.of(context).unfocus(); // Dismiss keyboard.
    setState(() => _isSubmitting = true);

    try {
      final newTask = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        goalIds: _selectedGoalIds,
        appearanceCount: _appearanceCount,
        importance: _importance,
        display:
            false, // New tasks are added to the pool, not displayed directly.
      );

      // Use the provider to handle task creation logic.
      await ref.read(taskProvider.notifier).createTask(newTask);

      if (mounted) {
        // Show a success message.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form to its initial state for the next entry.
        _formKey.currentState?.reset();
        setState(() {
          _titleController.clear();
          _descriptionController.clear();
          _appearanceController.text = '1';
          _selectedGoalIds = [];
          _appearanceCount = 1;
          _importance = 5;
        });
      }
    } catch (e) {
      if (mounted) {
        // Show an error message on failure.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Ensure the submitting state is reset regardless of outcome.
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Toggles the selection state of a goal chip.
  /// Adds or removes the goal's ID from the `_selectedGoalIds` list.
  /// Includes DEBUG logs to verify functionality.
  void _toggleGoalSelection(String goalId) {
    print("DEBUG: Toggling Goal ID: '$goalId' (Type: ${goalId.runtimeType})");
    print("DEBUG: Current Selection before toggle: $_selectedGoalIds");

    setState(() {
      if (_selectedGoalIds.contains(goalId)) {
        _selectedGoalIds.remove(goalId);
        print("DEBUG: Removed ID. Selection is now: $_selectedGoalIds");
      } else {
        _selectedGoalIds.add(goalId);
        print("DEBUG: Added ID. Selection is now: $_selectedGoalIds");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the goal provider to get the list of available goals for linking.
    final goals = ref.watch(goalProvider);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Main Form Card ---
            // Encapsulates the entire form within a styled Card.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24),

                    // --- Task Title Field ---
                    Showcase(
                      key: twelve,
                      title: title_twelve,
                      description: description_twelve,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(),
                        ),
                        // Validator ensures the title is not empty.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Task Description Field ---
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4, // Allows for a multi-line description.
                    ),
                    const SizedBox(height: 24),

                    // --- Appearance Count Section ---
                    Showcase(
                      key: thirteen,
                      title: title_thirteen,
                      description: description_thirteen,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Appearance Count',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              // A decorative chip to display the current count.
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_appearanceCount time${_appearanceCount > 1 ? 's' : ''}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Helper text to explain the purpose of this field.
                          Text(
                            'How many times this task appears before completion',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(153),
                                    ),
                          ),
                          const SizedBox(height: 12),
                          // Text field for direct numeric input.
                          TextFormField(
                            controller: _appearanceController,
                            decoration: const InputDecoration(
                              labelText: 'Enter number (1-100)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.repeat),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a number';
                              }
                              final numValue = int.tryParse(value);
                              if (numValue == null || numValue < 1) {
                                return 'Please enter a number greater than 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Slider for quick, visual selection of the count.
                          Slider(
                            value: _appearanceCount.toDouble(),
                            min: 1,
                            max: 100,
                            divisions: 99, // Allows for discrete steps.
                            label: _appearanceCount.toString(),
                            onChanged: _onAppearanceSliderChanged,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // --- Importance Level Section ---
                    Showcase(
                      key: fourteen,
                      title: title_fourteen,
                      description: description_fourteen,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Importance Level',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              // Displays the current importance rating.
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_importance/10',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Helper text for the importance slider.
                          Text(
                            'How important this task is (affects priority)',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(153),
                                    ),
                          ),
                          const SizedBox(height: 12),
                          // Slider for setting the importance level.
                          Slider(
                            value: _importance.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _importance.toString(),
                            onChanged: (value) {
                              setState(() {
                                _importance = value.round();
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // --- Goal Linking Section ---
                    // Conditionally displays either a list of goals or a prompt to create one.
                    Showcase(
                      key: fifteen,
                      title: title_fifteen,
                      description: description_fifteen,
                      child: goals.isNotEmpty
                          // STATE 1: Display goal selection chips if goals exist.
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Link to Goals (optional)',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                // Scrollable container for goal chips.
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      // Map each goal to a selectable FilterChip.
                                      children: goals.map((goal) {
                                        // FIX: Use goal.id explicitly to ensure we have a String
                                        final String goalId = goal.id;
                                        final isSelected =
                                            _selectedGoalIds.contains(goalId);

                                        return FilterChip(
                                          label: Text(goal.title),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            _toggleGoalSelection(goalId);
                                          },
                                          selectedColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withAlpha(51),
                                          checkmarkColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          showCheckmark: true,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            )
                          // STATE 2: Display a prompt to create goals if none exist.
                          : Card(
                              elevation: 0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No Goals Available',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Create goals first to link them to tasks.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 16),
                                    // Button to navigate to the "New Goal" page.
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        icon: const Icon(Icons.add),
                                        label: const Text('Create Goal'),
                                        onPressed: () =>
                                            context.push('/new-goal'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    // --- Form Action Buttons ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSubmitting ? null : () => context.pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _createTask,
                          // Show a loading indicator or text based on submission state.
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Create Task'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
