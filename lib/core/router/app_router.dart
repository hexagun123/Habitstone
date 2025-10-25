import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/main/presentation/pages/new_goal.dart';
import '../../../features/main/presentation/pages/main_page.dart';
import '../../../features/main/presentation/pages/new_task.dart';
import '../../../features/main/presentation/pages/display_page.dart';
import '../../../features/main/presentation/pages/stats.dart';
import '../../../features/main/presentation/pages/new_reward.dart';
import '../../../features/main/presentation/pages/setting.dart';

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
        path: '/new-goal',
        name: 'new-goal',
        builder: (context, state) => const NewGoalPage(),
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
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) => const StatsPage(),
      ),
      GoRoute(
        path: '/new-reward',
        name: 'new-reward',
        builder: (context, state) => const RewardPage(),
      ),
      GoRoute(
        path: '/setting',
        name: 'setting',
        builder: (context, state) => const SettingPage(),
      ),
    ],
  );
});
