// widgets/main_page/user_info.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/data/util.dart';
import '../../../../../core/provider/auth.dart'; // Ensure this path is correct

class InfoText extends ConsumerWidget {
  const InfoText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: authState.when(
          data: (user) {
            if (user == null) {
              // If the user is logged out, show the guest UI.
              return _buildGuestUI(context);
            } else {
              // If the user is logged in, show the personalized greeting.
              return _buildLoggedInUI(context, ref, user);
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text('Authentication error.')),
        ),
      ),
    );
  }

  /// Builds the UI for a logged-out (guest) user.
  Widget _buildGuestUI(BuildContext context) {
    final now = DateUtil.now();
    final formatter = DateFormat('EEEE, MMMM d, y');
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
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Sign In to Sync'),
              onPressed: () => context.go('/sign-in'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the UI for a logged-in user, including the logout button.
  Widget _buildLoggedInUI(BuildContext context, WidgetRef ref, User user) {
    final formatter = DateFormat('MMMM d, y');
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display user's avatar, with a fallback icon
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Icon(
                      Icons.person,
                      size: 28,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Greeting and Date are now grouped together
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${user.displayName?.split(' ').first ?? 'User'}!",
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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
        // Spacer pushes the button to the bottom of the card
        const Spacer(),
        // The Sign Out button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}