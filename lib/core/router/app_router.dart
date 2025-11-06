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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final authStream = ref.watch(authStateProvider.stream);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStream),
    routes: [
      GoRoute(
          path: '/',
          name: 'main',
          builder: (context, state) => const MainPage()),
      GoRoute(
          path: '/new-goal',
          name: 'new-goal',
          builder: (context, state) => const NewGoalPage()),
      GoRoute(
          path: '/new-task',
          name: 'new-task',
          builder: (context, state) => const NewTaskPage()),
      GoRoute(
          path: '/display',
          name: 'display',
          builder: (context, state) => const DisplayPage()),
      GoRoute(
          path: '/new-reward',
          name: 'new-reward',
          builder: (context, state) => const RewardPage()),
      GoRoute(
          path: '/setting',
          name: 'setting',
          builder: (context, state) => const SettingPage()),
      GoRoute(
          path: '/sign-in',
          name: 'sign-in',
          builder: (context, state) => const SignInScreen()),
    ],

    // --- UPDATED REDIRECT LOGIC ---
    // This no longer forces the user to the sign-in page.
    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading || authState.hasError) {
        return null; // Wait for state resolution
      }

      final isLoggedIn = authState.valueOrNull != null;
      final isGoingToSignIn = state.matchedLocation == '/sign-in';

      // Rule: If a user who IS logged in tries to visit the sign-in
      // page, redirect them to the main page.
      if (isLoggedIn && isGoingToSignIn) {
        return '/';
      }

      // No other rules are needed. Return null to allow navigation
      // for all other cases, including unauthenticated users.
      return null;
    },
  );
});

/// Rfrsh strm helper for GoRtr, translates Stream updates to ChangeNtfy calls.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    // Listen to the stream and notify GoRouter whenever an event occurs
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
