// lib/core/provider/auth.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../auth/auth_service.dart';
import '../data/sync.dart';
import 'app.dart';

final firebaseSyncProvider = Provider<FirebaseSync>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  return FirebaseSync(hiveRepo);
});

const String webClientId = String.fromEnvironment('WEB_CLIENT_ID');
const String desktopClientId = String.fromEnvironment('WEB_CLIENT_ID');
const String desktopClientSecret =
    String.fromEnvironment('DESKTOP_CLIENT_SECRET');

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  GoogleSignInParams params;
  if (kIsWeb) {
    params = GoogleSignInParams(
      clientId: webClientId,
      scopes: ['email', 'profile'],
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    params = GoogleSignInParams(
        clientId: desktopClientId,
        clientSecret: desktopClientSecret,
        scopes: ['email', 'profile'],
        redirectPort: 3000);
  } else {
    params = const GoogleSignInParams(
      scopes: ['email', 'profile'],
    );
    params = const GoogleSignInParams(
      scopes: ['email', 'profile'],
    );
  }
  return GoogleSignIn(params: params);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthService(googleSignIn);
});

final authStateControllerProvider = Provider((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  final authService = ref.watch(authServiceProvider);
  final syncService = ref.watch(firebaseSyncProvider);
  final hiveRepo = ref.watch(hiveRepositoryProvider);

  final sub = googleSignIn.authenticationState.listen((credentials) async {
    try {
      if (credentials != null) {
        // --- ON LOGIN ---
        final user =
            await authService.signInToFirebaseWithCredentials(credentials);
        if (user != null) {
          // STEP 1: Perform the initial data pull.
          await syncService.pullAllData();
          // STEP 2: Start listening for real-time updates.
          syncService.startRealtimeListeners();
        }
      } else {
        // --- ON LOGOUT ---
        // STEP 1: Stop listening to prevent errors and memory leaks.
        syncService.stopRealtimeListeners();
        // STEP 2: Clear all local data.
        await hiveRepo.clearAllBoxes();
      }
    } catch (e) {
      print("🛑 Uncaught error in authStateController: $e");
    }
  });

  ref.onDispose(() => sub.cancel());
});

final authStateProvider = StreamProvider<User?>((ref) {
  ref.watch(authStateControllerProvider);
  return ref.watch(authServiceProvider).authStateChanges;
});
