/// This file defines the NewGoalPage, which provides the user interface
/// for creating a new long-term goal. It includes a form for inputting
/// goal details and a section with examples to guide the user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/provider/goal.dart';
import '../../../../core/model/goal.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/data/showcase_key.dart';

/// The main page widget for creating a new goal.
///
/// It provides the basic layout structure (Scaffold, AppBar) and includes the [NewGoalForm].
class NewGoalPage extends ConsumerWidget {
  const NewGoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Goal'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Showcase widget to highlight the form during the app's tutorial.
            child: Showcase(
                key: eleven,
                title: title_eleven,
                description: description_eleven,
                child: const NewGoalForm()),
          ),
        ));
  }
}

/// A stateful widget that contains the form for creating a new goal.
class NewGoalForm extends ConsumerStatefulWidget {
  const NewGoalForm({super.key});

  @override
  ConsumerState<NewGoalForm> createState() => _NewGoalFormState();
}

/// The state associated with [NewGoalForm].
///
/// Manages the form's state, including text controllers for the goal's title
/// and description, validation logic, and the submission process.
class _NewGoalFormState extends ConsumerState<NewGoalForm> {
  // A global key that uniquely identifies the Form widget and allows for validation.
  final _formKey = GlobalKey<FormState>();
  // Controllers for managing the text input fields.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Tracks the submission state to show a loading indicator and disable buttons.
  bool _isSubmitting = false;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed to prevent memory leaks.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handles the goal creation process.
  ///
  /// This method validates the form, creates a new [Goal] object, calls the
  /// [goalProvider] to save it, shows a success or error message to the user,
  /// and finally resets the form before navigating back to the main page.
  Future<void> _createGoal() async {
    // Return early if form validation fails.
    if (!_formKey.currentState!.validate()) return;

    // Unfocus any active text fields to dismiss the keyboard.
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final newGoal = Goal(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      // Call the provider's method to create the goal.
      await ref.read(goalProvider.notifier).createGoal(newGoal);

      if (mounted) {
        // Show a success message to the user.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form fields to their initial state.
        _formKey.currentState?.reset();

        // Explicitly clear controllers after form reset.
        Future.delayed(Duration.zero, () {
          if (mounted) {
            setState(() {
              _titleController.clear();
              _descriptionController.clear();
            });
          }
        });

        // Navigate back to the home page after successful creation.
        context.go('/');
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
          // The main card containing the form fields.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form header.
                  Text(
                    'Goal Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Goal Title text field.
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Physical Health',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a goal title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Goal Description text field.
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Describe what you want to achieve...',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  // Form action buttons (Cancel, Create Goal).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        // Disable the button during submission.
                        onPressed: _isSubmitting ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        // Disable the button and show an indicator during submission.
                        onPressed: _isSubmitting ? null : _createGoal,
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
                            : const Text('Create Goal'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // A section providing examples of goals to guide the user.
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Goals help you track long-term improvements. Examples:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          const _ExampleGoalItem(
              title: 'Physical Health',
              description: 'Improve fitness and overall health'),
          const _ExampleGoalItem(
              title: 'Mental Wellness',
              description: 'Reduce stress and improve mindfulness'),
          const _ExampleGoalItem(
              title: 'Career Growth',
              description: 'Develop new professional skills'),
        ],
      ),
    );
  }
}

/// A private helper widget to display a single example goal item.
///
/// Used to provide users with ideas for what constitutes a good goal.
class _ExampleGoalItem extends StatelessWidget {
  final String title;
  final String description;

  const _ExampleGoalItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 8, color: Colors.grey),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
