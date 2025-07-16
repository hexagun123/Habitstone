import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/main/presentation/pages/main_page.dart';
import '../../../features/main/presentation/pages/new_task.dart';
import '../../../features/main/presentation/pages/display_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: '/new-task',
        name: 'new-task',
        builder: (context, state) => const NewTaskPage(),
      ),
      GoRoute(
        path: '/display',
        name: 'display',
        builder: (context, state) => const DisplayPage(),
      ),
    ],
  );
});