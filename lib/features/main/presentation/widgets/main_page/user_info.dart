import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // Added GoRouter import

class InfoText extends StatelessWidget {
  const InfoText({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, y');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 20,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                formatter.format(now),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(170),
                    ),
              ),
              const Spacer(),
              // Login Button added here
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () =>
                      context.push('/login'), // Navigation using named route
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
