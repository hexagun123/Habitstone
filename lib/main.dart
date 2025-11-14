import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:streak/core/model/quote.dart';
import 'core/model/goal.dart';
import 'core/model/task.dart';
import 'core/model/reward.dart';
import 'core/model/settings.dart';
import 'core/router/app_router.dart';
import 'core/provider/app.dart';
import 'core/provider/theme.dart';
import 'firebase_options.dart';
import 'core/provider/sync.dart';
import 'core/data/quote.dart';
// Note: path_provider is no longer needed here since Hive.initFlutter() handles it.

void main() async {
  // 1. Ensure Flutter framework is ready.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialize Hive using the recommended method for Flutter.
  // This handles finding the correct directory on both mobile and web.
  await Hive.initFlutter();

  // 4. Register all your Hive adapters.
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(RewardAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(QuoteAdapter());

  // 5. Run the app within a ProviderScope.
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a great pattern. Watching the sync controller to start it early.
    ref.watch(syncControllerProvider);

    // Watch the app initializer provider. Your UI is already perfectly set up
    // to handle its loading, error, and data states.
    final appInit = ref.watch(appInitializerProvider);
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);
    final quote = ref.watch(quoteProvider.notifier);

    quote.build();
    // This .when() clause is the correct way to build your UI.
    return appInit.when(
      data: (_) => MaterialApp.router(
        title: 'Habitstone',
        theme: theme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      ),
      error: (err, stack) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('App failed to load:\n\n$err'),
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
