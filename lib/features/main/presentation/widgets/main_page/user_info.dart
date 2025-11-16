// features/main/presentation/widgets/main_page/user_info.dart
// This file defines the `InfoText` widget, a UI component displayed on the main
// page. Its primary responsibility is to present user-specific information,
// dynamically adapting its content based on the current authentication state
// (logged in or guest).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/data/showcase_key.dart';
import '../../../../../core/data/util.dart';
import '../../../../../core/provider/auth.dart';

/// A widget that displays user information and authentication status.
///
/// As a [ConsumerWidget], it subscribes to the `authStateProvider` to reactively
/// build its UI. It shows a personalized greeting and user avatar for logged-in
// users, or a generic welcome and a "Sign In" button for guests.
class InfoText extends ConsumerWidget {
  const InfoText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state provider. The widget will rebuild whenever
    // the auth state changes (e.g., user logs in or out).
    final authState = ref.watch(authStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Use the `when` method to handle all possible states of the async auth provider.
        // This is a robust way to manage loading, error, and data states.
        child: authState.when(
          data: (user) {
            // Conditionally render the UI based on whether a user object exists.
            if (user == null) {
              return _buildGuestUI(context); // User is logged out.
            } else {
              return _buildLoggedInUI(context, ref, user); // User is logged in.
            }
          },
          // Show a spinner while the authentication state is being determined.
          loading: () => const Center(child: CircularProgressIndicator()),
          // Display an error message if authentication fails.
          error: (err, stack) =>
              const Center(child: Text('Authentication error.')),
        ),
      ),
    );
  }

  /// Builds the UI to be displayed for a guest (logged-out) user.
  ///
  /// This layout includes the current date and a prominent "Sign In" button
  /// to encourage user authentication. The button is also highlighted in the
  /// app's interactive tutorial.
  Widget _buildGuestUI(BuildContext context) {
    final now = DateUtil.now(); // Get current date.
    final formatter = DateFormat('EEEE, MMMM d, y'); // Format for display.

    return Column(
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
                color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
              ),
        ),
        Expanded(
          child: Center(
            child: Showcase(
              key: five,
              title: title_five,
              description: description_five,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign In to Sync'),
                // Navigate to the sign-in page on press.
                onPressed: () => context.go('/sign-in'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the UI for an authenticated (logged-in) user.
  ///
  /// This layout displays a personalized greeting with the user's name,
  /// their profile picture (or a default icon), and a "Sign Out" button.
  Widget _buildLoggedInUI(BuildContext context, WidgetRef ref, User user) {
    final formatter = DateFormat('MMMM d, y'); // Format for the current date.
    // Tries to get the user's first name from their display name.
    final firstName = user.displayName?.split(' ').first ?? 'User';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User's avatar with a fallback icon if no photo URL is available.
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null // Show icon if no image.
                  ? Icon(
                      Icons.person,
                      size: 28,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personalized greeting message.
                  Text(
                    "Hello, $firstName!",
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Current date display.
                  Text(
                    formatter.format(DateUtil.now()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(170),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(), // Pushes the sign-out button to the bottom of the card.
        SizedBox(
          width: double.infinity,
          // This `Showcase` is an easter egg for the tutorial if the user is logged in.
          child: Showcase(
            key: five,
            title: title_five,
            description: description_five,
            child: TextButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () {
                // Call the sign-out method from the authentication service.
                ref.read(authServiceProvider).signOut();
              },
              style: TextButton.styleFrom(
                // Use the theme's error color for a destructive action.
                foregroundColor: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
