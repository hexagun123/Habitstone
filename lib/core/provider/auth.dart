import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../auth/auth_service.dart';
import '../data/sync.dart';
import 'app.dart';
import '../model/environment.dart';

final firebaseSyncProvider = Provider<FirebaseSync>((ref) {
  // The sync service needs the Hive repository to do its job
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  return FirebaseSync(hiveRepo);
});

// Provider that creates the correctly configured GoogleSignIn instance
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  GoogleSignInParams params;
  if (kIsWeb) {
    params = GoogleSignInParams(
      clientId: Environment.webClientId,
      scopes: ['email', 'profile'],
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    params = GoogleSignInParams(
      clientId: Environment.desktopClientId,
      clientSecret: Environment.desktopClientSecret,
      scopes: ['email', 'profile'],
      redirectPort: 3000,
    );
  } else {
    params = const GoogleSignInParams(
      scopes: ['email', 'profile'],
    );
  }

  return GoogleSignIn(params: params);
});

// The AuthService provider now depends on the googleSignInProvider
final authServiceProvider = Provider<AuthService>((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthService(googleSignIn);
});

// --- THIS IS THE NEW, CRITICAL LOGIC ---
// This provider listens to Google's auth state. When it changes, it
// triggers a sign-in to Firebase.
final authStateControllerProvider = Provider((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  final authService = ref.watch(authServiceProvider);
  final syncService = ref.watch(firebaseSyncProvider); // Get sync service

  final sub = googleSignIn.authenticationState.listen((credentials) async {
    // Make async
    if (credentials != null) {
      print("Google Auth State Changed: Received credentials...");

      // --- TRIGGER THE PULL ON LOGIN ---
      // Sign in to Firebase first
      final user =
          await authService.signInToFirebaseWithCredentials(credentials);
      if (user != null) {
        // If Firebase sign-in is successful, pull all their data
        await syncService.pullAllData();
      }
    }
  });

  ref.onDispose(() => sub.cancel());
});

final authStateProvider = StreamProvider<User?>((ref) {
  ref.watch(authStateControllerProvider);
  return ref.watch(authServiceProvider).authStateChanges;
});
