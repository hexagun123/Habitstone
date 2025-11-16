import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:showcaseview/showcaseview.dart';

// --- Your Project's Core Imports ---
import 'core/model/quote.dart';
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
import 'core/data/showcase_key.dart'; // Import your keys

void main() async {
  // 1. Ensure Flutter framework is ready.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialize Hive.
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

// 1. Convert MyApp to a ConsumerStatefulWidget to use initState.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // 2. Read the router instance from your Riverpod provider.
    // We use ref.read because this is a one-time action inside a lifecycle method.
    final router = ref.read(routerProvider);

    // 3. Register ShowcaseView and its global callbacks here.
    // This setup runs only once when the app starts.
    ShowcaseView.register(
      enableAutoScroll: true,
      scrollDuration: const Duration(milliseconds: 500),

      // This global callback is our central controller for the automatic tour.
      onComplete: (index, key) {
        debugPrint('Showcase completed for key: $key');

        if (key == ten) {
          // ...automatically navigate to the new goal page.
          router.push('/new-goal');

          // After a short delay for the page transition animation...
          Future.delayed(const Duration(milliseconds: 400), () {
            // ...start the showcase for the keys on the new goal page.
            ShowcaseView.get().startShowCase([eleven]);
          });
        }

        if (key == eleven) {
          // ...automatically navigate to the new goal page.
          router.push('/new-task');

          // After a short delay for the page transition animation...
          Future.delayed(const Duration(milliseconds: 400), () {
            // ...start the showcase for the keys on the new goal page.
            ShowcaseView.get()
                .startShowCase([twelve, thirteen, fourteen, fifteen]);
          });
        }
        if (key == fifteen) {
          // ...automatically navigate to the new goal page.
          router.push('/new-reward');

          // After a short delay for the page transition animation...
          Future.delayed(const Duration(milliseconds: 400), () {
            // ...start the showcase for the keys on the new goal page.
            ShowcaseView.get().startShowCase([sixteen, seventeen, eighteen]);
          });
        }
        if (key == eighteen) {
          // ...automatically navigate to the new goal page.
          router.push('/display');

          // After a short delay for the page transition animation...
          Future.delayed(const Duration(milliseconds: 400), () {
            // ...start the showcase for the keys on the new goal page.
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
          // ...automatically navigate to the new goal page.
          router.push('/setting');

          // After a short delay for the page transition animation...
          Future.delayed(const Duration(milliseconds: 400), () {
            // ...start the showcase for the keys on the new goal page.
            ShowcaseView.get().startShowCase([twentySix, twentySeven, twentyEight]);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The build method logic remains the same.
    ref.watch(syncControllerProvider);
    final appInit = ref.watch(appInitializerProvider);
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);
    final quote = ref.watch(quoteProvider.notifier);
    quote.build();

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
