// core/router/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your auth providers and all your page files
import '../provider/auth.dart'; // Ensure this path is correct
import '../../../features/main/presentation/pages/new_goal.dart';
import '../../../features/main/presentation/pages/main_page.dart';
import '../../../features/main/presentation/pages/new_task.dart';
import '../../../features/main/presentation/pages/display_page.dart';
import '../../../features/main/presentation/pages/stats.dart';
import '../../../features/main/presentation/pages/new_reward.dart';
import '../../../features/main/presentation/pages/setting.dart';
import '../../../features/main/presentation/pages/sign_in.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // We still watch the state to use it in the redirect logic
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',

    // --- THE FIX IS HERE ---
    // To get the actual stream, we access the provider's .stream property
    refreshListenable:
        GoRouterRefreshStream(ref.watch(authStateProvider.stream)),

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
          path: '/stats',
          name: 'stats',
          builder: (context, state) => const StatsPage()),
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

    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading || authState.hasError) {
        return null;
      }

      final isLoggedIn = authState.valueOrNull != null;
      final isGoingToSignIn = state.matchedLocation == '/sign-in';

      if (isLoggedIn && isGoingToSignIn) {
        return '/';
      }

      final isPublicPage = state.matchedLocation == '/' || isGoingToSignIn;
      if (!isLoggedIn && !isPublicPage) {
        return '/sign-in';
      }

      return null;
    },
  );
});

// This helper class is correct and needs no changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
