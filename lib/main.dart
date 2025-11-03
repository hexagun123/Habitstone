import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Only the most essential, non-Riverpod initializations remain here
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  if (!kIsWeb) {
    // For any platform that is NOT web (mobile, desktop)
    // we get a safe directory and initialize Hive there.
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(RewardAdapter());
  Hive.registerAdapter(SettingsAdapter());

  // GoogleSignIn is now initialized inside its provider, not here

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncControllerProvider);

    final appInit = ref.watch(appInitializerProvider);
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeProvider);

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
