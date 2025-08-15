import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/provider/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/model/goal.dart';
import 'core/model/task.dart';
import 'core/data/hive.dart';
import 'core/provider/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TaskAdapter());
  final repository = HiveRepository();
  await repository.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(
    overrides: [
      hiveRepositoryProvider
          .overrideWithValue(repository), // Use the new provider
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

    return MaterialApp.router(
      title: 'Habitstone',
      theme: theme,
      themeMode: ThemeMode.light, // Force our custom theme to always be used
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
