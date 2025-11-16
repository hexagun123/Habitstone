/// This file defines the UI and logic for the "New Task" page, allowing users
/// to create and configure new tasks. It includes a form for inputting task details
/// like title, description, appearance count, importance, and linking to existing goals.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../core/data/showcase_key.dart';
import '../../../../core/model/task.dart';
import '../../../../core/provider/goal.dart';
import '../../../../core/provider/task.dart';

/// The main page widget for creating a new task.
/// It provides the basic layout structure (Scaffold and AppBar).
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

/// A stateful widget that contains the form for creating a new task.
class NewTaskForm extends ConsumerStatefulWidget {
  const NewTaskForm({super.key});

  @override
  ConsumerState<NewTaskForm> createState() => _NewTaskFormState();
}

/// The state associated with [NewTaskForm].
/// It manages the form's state, including text controllers, validation,
/// and submission logic.
class _NewTaskFormState extends ConsumerState<NewTaskForm> {
  // A global key that uniquely identifies the Form widget and allows validation.
  final _formKey = GlobalKey<FormState>();
  // Controllers for managing the text input fields.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _appearanceController = TextEditingController(text: '1');
  // State variables for form logic.
  bool _isSubmitting =
      false; // Tracks submission state to show loading indicator.
  List<String> _selectedGoalIds = []; // Stores keys of linked goals.
  int _appearanceCount = 1; // Stores the value for the appearance slider/field.
  int _importance = 5; // Stores the value for the importance slider.

  @override
  void initState() {
    super.initState();
    // Listen for changes in the appearance text field to sync state.
    _appearanceController.addListener(_onAppearanceTextChanged);
  }

  /// Synchronizes the `_appearanceCount` state variable with the text field.
  /// It parses the text, clamps the value between 1 and 100, and updates
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

        // If the entered value was out of bounds, update the text field.
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

  /// Updates the `_appearanceCount` and the corresponding text field when the slider is changed.
  void _onAppearanceSliderChanged(double value) {
    final intValue = value.round();
    setState(() {
      _appearanceCount = intValue;
      _appearanceController.text = intValue.toString();
    });
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks.
    _titleController.dispose();
    _descriptionController.dispose();
    _appearanceController.removeListener(_onAppearanceTextChanged);
    _appearanceController.dispose();
    super.dispose();
  }

  /// Handles the task creation process.
  /// It validates the form, creates a new Task object, calls the provider
  /// to save it, shows feedback to the user, and resets the form.
  Future<void> _createTask() async {
    // Abort if the form is not valid.
    if (!_formKey.currentState!.validate()) return;

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

      // Call the provider to handle the creation logic.
      await ref.read(taskProvider.notifier).createTask(newTask);

      if (mounted) {
        // Show success message.
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
        // Show error message on failure.
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
  void _toggleGoalSelection(String goalId) {
    setState(() {
      if (_selectedGoalIds.contains(goalId)) {
        _selectedGoalIds.remove(goalId);
      } else {
        _selectedGoalIds.add(goalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the goal provider to get the list of available goals.
    final goals = ref.watch(goalProvider);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main form card
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
                    // Task Title field
                    Showcase(
                      key: twelve,
                      title: "new task",
                      description:
                          "Enter the task title here,task are recommanded to be short ones that you can complete in a short period of time, such as 45 mintues",
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Task Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    // Appearance Count section
                    Showcase(
                      key: thirteen,
                      title: "appearance",
                      description:
                          "For each task you can set the amount of time that a task could appear, this is for simpilfying the work flow, as not a lot of people want to create a lot of tasks - it will be a mess.",
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
                          Slider(
                            value: _appearanceCount.toDouble(),
                            min: 1,
                            max: 100,
                            divisions: 99,
                            label: _appearanceCount.toString(),
                            onChanged: _onAppearanceSliderChanged,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // Importance Level section
                    Showcase(
                      key: fourteen,
                      title: "Importance",
                      description:
                          "foundation of random generation of tasks, the higher the importance the more likely that this task get generated first",
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
                    // Goal Linking section (conditional)
                    if (goals.isNotEmpty) ...[
                      Showcase(
                          key: fifteen,
                          title: "goal linking",
                          description:
                              "by subscribing a task to a goal, you could increase the streak of it by simply completing this task, a task could of-course, link to multiple goals.",
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Link to Goals (optional)',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: goals.map((goal) {
                                        final isSelected =
                                            _selectedGoalIds.contains(goal.key);
                                        return FilterChip(
                                          label: Text(goal.title),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            if (goal.key != null) {
                                              _toggleGoalSelection(goal.key!);
                                            }
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
                              ]))
                    ],
                    // Form action buttons
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
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2), // Loading indicator
                                )
                              : const Text('Create Task'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // "No Goals" prompt (conditional)
            if (goals.isEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Goals Available',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create goals first to link them to tasks',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Create Goal'),
                          onPressed: () => context.push('/new-goal'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
