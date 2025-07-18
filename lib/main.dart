import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/provider/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/model/goal.dart';
import 'core/model/task.dart';
import 'core/data/hive.dart';
import 'core/provider/goal.dart';
import 'core/provider/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TaskAdapter());
  final repository = HiveRepository();
  await repository.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WindowManager.instance.setMinimumSize(const Size(1280, 900));
  runApp(ProviderScope(
    overrides: [
      hiveRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);
    ref.read(goalProvider.notifier);
    ref.read(taskProvider.notifier);

    return MaterialApp.router(
      title: 'My App',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
