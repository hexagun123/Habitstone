/// This file configures the application's routing using the GoRouter package.
/// It defines all the navigation paths and implements authentication-based
/// redirection logic with the help of Riverpod for state management.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth.dart';
import '../../../features/main/presentation/pages/new_goal.dart';
import '../../../features/main/presentation/pages/main_page.dart';
import '../../../features/main/presentation/pages/new_task.dart';
import '../../../features/main/presentation/pages/display_page.dart';
import '../../../features/main/presentation/pages/new_reward.dart';
import '../../../features/main/presentation/pages/setting.dart';
import '../../../features/main/presentation/pages/sign_in.dart';

/// Provides the GoRouter instance to the widget tree.
/// This provider watches the authentication state and uses it to manage routing rules.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final authStream = ref.watch(authStateProvider.stream);

  return GoRouter(
    initialLocation: '/', // The default route when the app starts.
    // Listens to the authentication stream to rebuild the navigation stack on auth changes.
    refreshListenable: GoRouterRefreshStream(authStream),
    routes: [
      // Main application page.
      GoRoute(
          path: '/',
          name: 'main',
          builder: (context, state) => const MainPage()),
      // Page for creating a new goal.
      GoRoute(
          path: '/new-goal',
          name: 'new-goal',
          builder: (context, state) => const NewGoalPage()),
      // Page for creating a new task.
      GoRoute(
          path: '/new-task',
          name: 'new-task',
          builder: (context, state) => const NewTaskPage()),
      // Page for displaying details or content.
      GoRoute(
          path: '/display',
          name: 'display',
          builder: (context, state) => const DisplayPage()),
      // Page for creating a new reward.
      GoRoute(
          path: '/new-reward',
          name: 'new-reward',
          builder: (context, state) => const RewardPage()),
      // Application settings page.
      GoRoute(
          path: '/setting',
          name: 'setting',
          builder: (context, state) => const SettingPage()),
      // User sign-in page.
      GoRoute(
          path: '/sign-in',
          name: 'sign-in',
          builder: (context, state) => const SignInScreen()),
    ],

    /// Redirects the user based on their authentication status.
    /// This logic prevents logged-in users from accessing the sign-in page.
    redirect: (BuildContext context, GoRouterState state) {
      // While auth state is resolving, don't redirect.
      if (authState.isLoading || authState.hasError) {
        return null;
      }

      final isLoggedIn =
          authState.valueOrNull != null; // Check if a user object exists.
      final isGoingToSignIn = state.matchedLocation ==
          '/sign-in'; // Check if the target route is the sign-in page.

      // If a logged-in user tries to navigate to the sign-in page,
      // redirect them back to the main application page.
      if (isLoggedIn && isGoingToSignIn) {
        return '/';
      }

      // In all other cases, allow the navigation to proceed without redirection.
      return null;
    },
  );
});

/// A custom `ChangeNotifier` that bridges a `Stream` to a `Listenable`.
/// GoRouter's `refreshListenable` requires a `Listenable`, but Riverpod providers
/// expose a `Stream`. This class listens to the stream and calls `notifyListeners()`
/// for each event, triggering GoRouter to re-evaluate its routes.
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates an instance that listens to the given stream.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    // Subscribe to the stream and notify listeners upon receiving an event.
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
