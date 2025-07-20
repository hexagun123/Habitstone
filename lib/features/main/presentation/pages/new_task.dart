import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/provider/task.dart';
import '../../../../core/model/task.dart';
import '../../../../core/provider/goal.dart'; // Added import

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
  bool _isSubmitting = false;
  List<int> _selectedGoalIds = []; // Track selected goal IDs

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
        goalIds: _selectedGoalIds, // Assign selected goals
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

        // Clear form and selection
        _formKey.currentState?.reset();
        setState(() {
          _titleController.clear();
          _descriptionController.clear();
          _selectedGoalIds = [];
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

  // Toggle goal selection
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
                    'Task Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
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
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

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
    );
  }
}
