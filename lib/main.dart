// main.dart
// This file serves as the primary entry point for the Habitstone application.
// It handles the critical initialization sequence for all core services,
// including Firebase, the local Hive database, and state management, before
// launching the user interface.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:showcaseview/showcaseview.dart';

// --- Project-Specific Core Imports ---
import 'core/data/quote.dart';
import 'core/data/showcase_key.dart';
import 'core/model/goal.dart';
import 'core/model/quote.dart';
import 'core/model/reward.dart';
import 'core/model/settings.dart';
import 'core/model/task.dart';
import 'core/provider/app.dart';
import 'core/provider/sync.dart';
import 'core/provider/theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

/// The main function and application entry point.
///
/// This asynchronous function ensures that all required services are initialized
/// in the correct order before the Flutter application is run. This prevents
//  runtime errors related to uninitialized dependencies.
void main() async {
  // Ensure the Flutter framework's bindings are initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the connection to Firebase for backend services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the Hive database for local on-device storage.
  await Hive.initFlutter();

  // Register Hive adapters to enable serialization of custom data models.
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(RewardAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(QuoteAdapter());

  // Launch the application within a ProviderScope to enable Riverpod state management.
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

/// The root widget of the application.
///
/// This is a [ConsumerStatefulWidget] to access the `initState` lifecycle
/// method, which is necessary for performing one-time setup tasks like
/// configuring the app's interactive tutorial.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

/// The state associated with the [MyApp] widget.
class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeShowcaseView();
  }

  /// Configures the global settings for the ShowcaseView interactive tutorial.
  ///
  /// This method centralizes the tutorial's logic, defining an automated,
  /// multi-page tour that guides new users through the app's core features.
  void _initializeShowcaseView() {
    // Read the router once for navigation, as it won't change during this lifecycle.
    final router = ref.read(routerProvider);

    ShowcaseView.register(
      enableAutoScroll: true,
      scrollDuration: const Duration(milliseconds: 500),

      // This callback programmatically controls the flow of the tutorial.
      // When one showcase step completes, it navigates to the next relevant
      // screen and starts the subsequent set of showcases.
      onComplete: (index, key) {
        debugPrint('Showcase completed for key: $key');

        // Defines the sequence of navigation and showcase activation.
        if (key == ten) {
          router.push('/new-goal');
          Future.delayed(const Duration(milliseconds: 400), () {
            ShowcaseView.get().startShowCase([eleven]);
          });
        }
        if (key == eleven) {
          router.push('/new-task');
          Future.delayed(const Duration(milliseconds: 400), () {
            ShowcaseView.get()
                .startShowCase([twelve, thirteen, fourteen, fifteen]);
          });
        }
        if (key == fifteen) {
          router.push('/new-reward');
          Future.delayed(const Duration(milliseconds: 400), () {
            ShowcaseView.get().startShowCase([sixteen, seventeen, eighteen]);
          });
        }
        if (key == eighteen) {
          router.push('/display');
          Future.delayed(const Duration(milliseconds: 400), () {
            ShowcaseView.get().startShowCase([
              nineteen,
              twenty,
              twentyOne,
              twentyTwo,
              twentyThree,
              twentyFour,
              twentyFive
            ]);
          });
        }
        if (key == twentyThree) {
          router.push('/setting');
          Future.delayed(const Duration(milliseconds: 400), () {
            ShowcaseView.get()
                .startShowCase([twentySix, twentySeven, twentyEight]);
          });
        }
      },
    );
  }

  /// Builds the main application widget tree.
  ///
  /// This method listens to the state of application providers and constructs
  /// the UI accordingly. It uses an `AsyncValue.when` clause to gracefully
  /// handle loading and error states during app initialization.
  @override
  Widget build(BuildContext context) {
    // Watch essential providers to trigger rebuilds on state changes.
    ref.watch(
        syncControllerProvider); // Keeps the background sync service active.
    final appInit = ref.watch(appInitializerProvider);
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);

    // Ensure the daily quote is loaded.
    ref.watch(quoteProvider.notifier).build();

    // Handle the different states of the asynchronous app initialization.
    return appInit.when(
      // On successful initialization, display the main app.
      data: (_) => MaterialApp.router(
        title: 'Habitstone',
        theme: theme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),

      // While initializing, show a loading indicator.
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      ),

      // If an error occurs, display an informative error screen.
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('App failed to load:\n\n$err'),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
