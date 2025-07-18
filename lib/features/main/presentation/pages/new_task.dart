import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/provider/task.dart'; // Add this import
import '../../../../core/model/task.dart'; // Add this import

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
  bool _isSubmitting = false; // Track submission state

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    // Unfocus keyboard first
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final newTask = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      await ref.read(taskProvider.notifier).createTask(newTask);

      if (mounted) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form state
        _formKey.currentState?.reset();

        // Clear controllers in the next frame
        Future.delayed(Duration.zero, () {
          if (mounted) {
            setState(() {
              _titleController.clear();
              _descriptionController.clear();
            });
          }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => context.go('/'),
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
        ],
      ),
    );
  }
}
