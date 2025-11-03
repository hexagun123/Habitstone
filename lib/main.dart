import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:streak/core/model/environment.dart'; // Environment model wasn't used in this scope, keeping it commented unless necessary
import 'core/model/goal.dart';
import 'core/model/task.dart';
import 'core/model/reward.dart';
import 'core/model/settings.dart';
import 'core/router/app_router.dart';
import 'core/provider/app.dart';
import 'core/provider/theme.dart';
import 'firebase_options.dart';
import 'core/provider/sync.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Conditional Hive Path Initialization (for non-Web platforms)
  if (!kIsWeb) {
    // Get a safe directory and initialize Hive there.
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  // 2. Firebase Initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Hive Initialization (must run even for web)
  await Hive.initFlutter();

  // 4. Register Adapters
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(RewardAdapter());
  Hive.registerAdapter(SettingsAdapter());

  // 5. Start the Application
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the sync controller to ensure it starts listening to auth/data changes early
    ref.watch(syncControllerProvider);

    // Watch the application initialization future (loading Hive data, etc.)
    final appInit = ref.watch(appInitializerProvider);
    
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);

    // Handle loading, data, and error states based on app initialization
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
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('App failed to load: $err'))),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}