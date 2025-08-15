// main.dart

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

// main function, get called when ran
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // init flutter
  await Hive.initFlutter(); // init hive
  Hive.registerAdapter(GoalAdapter()); // init hive with goal
  Hive.registerAdapter(TaskAdapter()); // init hive with task
  final repository = HiveRepository(); // define of hive repo, see core/data/hive.dart
  await repository.init(); // init the repo
  await Firebase.initializeApp( // firebase stuff
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

// the builder of the app
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);

    return MaterialApp.router( // return the router so display correctly
      title: 'Habitstone',
      theme: theme,
      themeMode: ThemeMode.light, // Force our custom theme to always be used
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
