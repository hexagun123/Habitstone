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

import '../../../../../../core/data/showcase_key.dart';
import '../../../../../../core/data/util.dart';
import '../../../../../../core/provider/auth.dart';

// widget for user info
class InfoText extends ConsumerWidget {
  const InfoText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch if authentication did something
    final authState = ref.watch(authStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // when handles the asyncData that providers give
        child: authState.when(
          data: (user) {
            // if there is data
            if (user == null) {
              return _buildGuestUI(context); // User is logged out
            } else {
              return _buildLoggedInUI(context, ref, user); // User is logged in
            }
          },
          // Loading screen, only shows if your internet or laptop is really bad
          loading: () => const Center(
              child: Text("Can you even see me? Anyways I am loading...")),
          // Display an error somehow if something went wrong
          error: (err, stack) =>
              const Center(child: Text('Authentication error.')),
        ),
      ),
    );
  }

  /// Builds the UI to be displayed for a guest. Just includes a signin button
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
              ), // changed a bit of the theme - copywith is useful in this case to respect the const
        ),
        const SizedBox(height: 8), // a bit of a gap
        Text(
          formatter.format(now),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(170), // same thing
              ),
        ),
        Expanded(
          child: Center(
            child: Showcase(
              // yay another showcase
              key: five,
              title: title_five,
              description: description_five,
              child: ElevatedButton.icon( // the login button
                icon: const Icon(Icons.login),
                label: const Text('Sign In to Sync'),
                onPressed: () => context.push('/sign-in'), //push so you can head back
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary, // grabbing from the theme
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  // this is the ui for logged in users
  Widget _buildLoggedInUI(BuildContext context, WidgetRef ref, User user) {
    final formatter = DateFormat('MMMM d, y'); // Format for the current date.
    // grabbing the first name of the user from firebase
    final firstName = user.displayName?.split(' ').first ?? 'User';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User's avatar with a fallback icon if no photo URL is available.
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surface,
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null, // network image fetches the photo from a url
              child: user.photoURL == null // Show icon if no image.
                  ? Icon(
                      Icons.person, // avg anonymous icon
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
                  // Nice greeting, why not?
                  Text(
                    "Hello, $firstName!",
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // date
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
        const Spacer(), // a gap
        SizedBox(
          width: double.infinity,
          // This is sort of an easter egg, because it doesn't appear before user logs in
          child: Showcase(
            key: five,
            title: title_five,
            description: description_five,
            child: TextButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () {
                ref.read(authServiceProvider).signOut(); // one time method get, signs you out
              },
              style: TextButton.styleFrom(
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
