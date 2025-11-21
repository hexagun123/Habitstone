// main.dart
// This is the main entry point
// nothing special, just some initialization, showcase running, and run the main app

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:showcaseview/showcaseview.dart';
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

// main function
// async because everything can come in late
void main() async {
  // initalise flutter bindings for libarary
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase dependent on the platform - good to do otherwise things crash
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // init hive
  await Hive.initFlutter();

  // Register typeadapters for hive: translate binary into hive objects
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(RewardAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(QuoteAdapter());

  // 3,2,1 launch yay! In a provider scope so provider works
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

// Needs a state for the showcase to work
// so it is in a consumer stateful widget now
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  // create a state for showcase
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeShowcaseView(); // calls the function
  }

  /// Head quarter
  void _initializeShowcaseView() {
    ShowcaseView.register(
        globalFloatingActionWidget: (context) {
    return FloatingActionWidget(
      top: 40,
      right: 10,
      child: TextButton(
        onPressed: () {
          // This stops the tutorial
          ShowcaseView.get().dismiss();
        },
        child: const Text(
          "Skip", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  },
      enableAutoScroll:
          true, // so when the showcase is offpage it scrolls to it
      scrollDuration:
          const Duration(milliseconds: 500), // how long the scroll is

      // on complete
      onComplete: (index, key) {
        // grabbing the router provider here so that we can navigate pages
        final router = ref.read(routerProvider);

        // set of if statements to check when to switch pages
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
        if (key == twentyFive) {
          router.go('/');
          router.push('/setting');
          Future.delayed(const Duration(milliseconds: 400), () {
            ShowcaseView.get()
                .startShowCase([twentySix, twentySeven, twentyEight]);
          });
        }
      },
    );
  }

  /// builds everything up
  @override
  Widget build(BuildContext context) {
    // Watch providers... yeah
    ref.watch(
        syncControllerProvider); // Keeps the background sync service active.
    final appInit = ref.watch(appInitializerProvider);
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);

    // watch the quote provider and tells it to pull the quotes from csv/check hive on startup
    ref.watch(quoteProvider.notifier).build();

    return appInit.when(
      // success, just build
      data: (_) => MaterialApp.router(
        title: 'Habitstone',
        theme: theme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),

      // While initializing, show a loading indicator.
      loading: () => const MaterialApp(
        home: Scaffold(
            body:
                Center(child: Text('yeah the app is loading, be patient...'))), // only is visable if your laptop or wifi is really bad
        debugShowCheckedModeBanner: false,
      ),

      // If there is an error, somehow? there is an error screen
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
