/// This file configures authentication services for the application using Riverpod.
/// It sets up Google Sign-In for multiple platforms, provides an authentication service,
/// and orchestrates data synchronization based on the user's authentication state.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../auth/auth_service.dart';
import '../data/sync.dart';
import 'app.dart';

/// Provides the [FirebaseSync] service instance.
/// This service handles the logic for synchronizing data between the local
/// Hive database and the remote Firebase Firestore.
final firebaseSyncProvider = Provider<FirebaseSync>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  return FirebaseSync(hiveRepo);
});

/// Defines compile-time constants for Google Sign-In client IDs.
/// These values are passed to the application at build time using the
/// `--dart-define` flag.
const String webClientId = String.fromEnvironment('WEB_CLIENT_ID');
const String desktopClientId = String.fromEnvironment('DESKTOP_CLIENT_ID');
const String desktopClientSecret =
    String.fromEnvironment('DESKTOP_CLIENT_SECRET');

/// Configures and provides the [GoogleSignIn] instance.
/// It uses platform-specific parameters to correctly initialize Google Sign-In
/// for web, desktop (Windows, Linux, macOS), and mobile platforms.
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  GoogleSignInParams params;
  if (kIsWeb) {
    // Configuration for web platforms.
    params = GoogleSignInParams(
      clientId: webClientId,
      scopes: ['email', 'profile'],
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Configuration for desktop platforms.
    params = GoogleSignInParams(
        clientId: desktopClientId,
        clientSecret: desktopClientSecret,
        scopes: ['email', 'profile'],
        redirectPort: 5000);
  } else {
    // Default configuration for mobile (iOS/Android).
    params = const GoogleSignInParams(
      scopes: ['email', 'profile'],
    );
  }
  return GoogleSignIn(params: params);
});

/// Provides the [AuthService] instance.
/// This service abstracts the underlying authentication logic, wrapping
/// Firebase Auth and Google Sign-In functionalities.
final authServiceProvider = Provider<AuthService>((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthService(googleSignIn);
});

/// A controller provider that listens to Google Sign-In authentication state changes
/// to orchestrate critical data synchronization and cleanup tasks.
/// This provider does not return a value but manages side effects based on auth state.
final authStateControllerProvider = Provider((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  final authService = ref.watch(authServiceProvider);
  final syncService = ref.watch(firebaseSyncProvider);
  final hiveRepo = ref.watch(hiveRepositoryProvider);

  // Listens to the raw authentication state from the Google Sign-In plugin.
  final sub = googleSignIn.authenticationState.listen((credentials) async {
    try {
      if (credentials != null) {
        // --- ON LOGIN ---
        // When Google credentials are available, sign in to Firebase.
        final user =
            await authService.signInToFirebaseWithCredentials(credentials);
        if (user != null) {
          // First, pull all data from Firebase to ensure local cache is up-to-date.
          await syncService.pullAllData();
          // Second, start real-time listeners for ongoing updates from Firebase.
          syncService.startRealtimeListeners();
        }
      } else {
        // --- ON LOGOUT ---
        // When credentials become null, the user has signed out.
        // First, stop listening to remote changes to prevent errors.
        syncService.stopRealtimeListeners();
        // Second, clear all user-specific data from the local Hive database.
        await hiveRepo.clearAllBoxes();
      }
    } catch (e) {
      // Catch and log any unexpected errors during the auth/sync process.
    }
  });

  // Ensure the stream subscription is cancelled when the provider is disposed.
  ref.onDispose(() => sub.cancel());
});

/// Provides the authentication state of the Firebase user.
/// This is the primary provider that UI components should watch to react to
/// sign-in or sign-out events. It exposes the `authStateChanges` stream
/// from the AuthService.
final authStateProvider = StreamProvider<User?>((ref) {
  // Watch the controller to ensure the auth-driven side effects are active.
  ref.watch(authStateControllerProvider);
  return ref.watch(authServiceProvider).authStateChanges;
});
