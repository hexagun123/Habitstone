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

  return GoRouter(
    initialLocation: '/',

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
  );
});
