import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/provider/task.dart';
import '../../../../core/model/task.dart';
import '../../../../core/provider/goal.dart';

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

class NewTaskForm extends ConsumerStatefulWidget {
  const NewTaskForm({super.key});

  @override
  ConsumerState<NewTaskForm> createState() => _NewTaskFormState();
}

class _NewTaskFormState extends ConsumerState<NewTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _appearanceController = TextEditingController(text: '1');
  bool _isSubmitting = false;
  List<int> _selectedGoalIds = [];

  int _appearanceCount = 1;
  int _importance = 5;

  @override
  void initState() {
    super.initState();
    _appearanceController.addListener(_onAppearanceTextChanged);
  }

  void _onAppearanceTextChanged() {
    final text = _appearanceController.text;
    if (text.isNotEmpty) {
      final value = int.tryParse(text) ?? 1;
      final clampedValue = value.clamp(1, 100);
      if (clampedValue != _appearanceCount) {
        setState(() {
          _appearanceCount = clampedValue;
        });
        // Update text field if value was clamped
        if (value != clampedValue) {
          _appearanceController.text = clampedValue.toString();
          _appearanceController.selection = TextSelection.fromPosition(
            TextPosition(offset: _appearanceController.text.length),
          );
        }
      }
    }
  }

  void _onAppearanceSliderChanged(double value) {
    final intValue = value.round();
    setState(() {
      _appearanceCount = intValue;
      _appearanceController.text = intValue.toString();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _appearanceController.removeListener(_onAppearanceTextChanged);
    _appearanceController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final newTask = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        goalIds: _selectedGoalIds,
        appearanceCount: _appearanceCount,
        importance: _importance,
        display: false,
      );

      await ref.read(taskProvider.notifier).createTask(newTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form and reset to defaults
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

  void _toggleGoalSelection(int goalId) {
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
    final goals = ref.watch(goalProvider);

    return SingleChildScrollView(
      child: Form(
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
                      'Task Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24),

                    // Task Title
                    TextFormField(
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
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Appearance Count Section
                    Column(
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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

                        // Number Input Field
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

                        // Slider
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

                    // Importance Slider
                    Column(
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

                    // Goal Selection Section
                    if (goals.isNotEmpty) ...[
                      Text(
                        'Link to Goals (optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
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
                                onSelected: (_) =>
                                    _toggleGoalSelection(goal.key!),
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha(51),
                                checkmarkColor:
                                    Theme.of(context).colorScheme.primary,
                                showCheckmark: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action Buttons
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

            // Goal creation prompt
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
