// core/router/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
// core/router/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth.dart';
import '../../../features/main/presentation/pages/new_goal.dart';
import '../../../features/main/presentation/pages/main_page.dart';
import '../../../features/main/presentation/pages/new_task.dart';
import '../../../features/main/presentation/pages/display_page.dart';
import '../../../features/main/presentation/pages/stats.dart';
import '../../../features/main/presentation/pages/new_reward.dart';
import '../../../features/main/presentation/pages/setting.dart';
import '../../../features/main/presentation/pages/sign_in.dart';
import '../../../features/main/presentation/pages/sign_in.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',

    // This is still needed so the app can navigate automatically AFTER a successful sign-in.
    refreshListenable:
        GoRouterRefreshStream(ref.watch(authStateProvider.stream)),

    routes: [
      // Your routes are unchanged.
      GoRoute(
          path: '/',
          name: 'main',
          builder: (context, state) => const MainPage()),
          path: '/',
          name: 'main',
          builder: (context, state) => const MainPage()),
      GoRoute(
          path: '/new-goal',
          name: 'new-goal',
          builder: (context, state) => const NewGoalPage()),
          path: '/new-goal',
          name: 'new-goal',
          builder: (context, state) => const NewGoalPage()),
      GoRoute(
          path: '/new-task',
          name: 'new-task',
          builder: (context, state) => const NewTaskPage()),
          path: '/new-task',
          name: 'new-task',
          builder: (context, state) => const NewTaskPage()),
      GoRoute(
          path: '/display',
          name: 'display',
          builder: (context, state) => const DisplayPage()),
          path: '/display',
          name: 'display',
          builder: (context, state) => const DisplayPage()),
      GoRoute(
          path: '/stats',
          name: 'stats',
          builder: (context, state) => const StatsPage()),
          path: '/stats',
          name: 'stats',
          builder: (context, state) => const StatsPage()),
      GoRoute(
          path: '/new-reward',
          name: 'new-reward',
          builder: (context, state) => const RewardPage()),
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
          path: '/setting',
          name: 'setting',
          builder: (context, state) => const SettingPage()),
      GoRoute(
          path: '/sign-in',
          name: 'sign-in',
          builder: (context, state) => const SignInScreen()),
    ],

    // --- THE NEW, SIMPLE REDIRECT LOGIC ---
    redirect: (BuildContext context, GoRouterState state) {
      // While checking auth state, don't do anything.
      if (authState.isLoading || authState.hasError) {
        return null;
      }

      final isLoggedIn = authState.valueOrNull != null;
      final isGoingToSignIn = state.matchedLocation == '/sign-in';

      // This is now the ONLY rule.
      // If a logged-in user tries to go to the sign-in page, send them home.
      if (isLoggedIn && isGoingToSignIn) {
        return '/';
      }

      // For every other case, do nothing. Let the user go where they want.
      return null;
    },
  );
});

// This helper class is still necessary for the refreshListenable to work.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
