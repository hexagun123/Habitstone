// everything about authentication and firebase

import 'dart:io' show Platform;
import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../auth/auth_service.dart';
import '../data/sync.dart';
import 'app.dart';

/// a provider for the syncing between local and cloud
/// just watching the hive repo so that we can call the data functions
final firebaseSyncProvider = Provider<FirebaseSync>((ref) {
  final hiveRepo = ref.watch(hiveRepositoryProvider);
  return FirebaseSync(hiveRepo);
});

/// all the environment variables
/// please if you want to run anything just get api from firebase and throw them here
/// I baked my env variables in when compiling, this is why it is fromEnvironment
const String webClientId = String.fromEnvironment('WEB_CLIENT_ID');
const String desktopClientId = String.fromEnvironment('DESKTOP_CLIENT_ID');
const String desktopClientSecret =
    String.fromEnvironment('DESKTOP_CLIENT_SECRET');

/// Google signin, very convient as there is quite a lot of google users :D
/// this function only does the config though
/// the actual functions are in AuthService, the one below
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  GoogleSignInParams params;
  if (kIsWeb) {
    // web config
    params = GoogleSignInParams(
      clientId: webClientId,
      scopes: ['email', 'profile'],
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // desktop config
    params = GoogleSignInParams(
        clientId: desktopClientId,
        clientSecret: desktopClientSecret,
        scopes: ['email', 'profile'],
        redirectPort:
            5000); // I've only allowed 5000 on my firebase as it is pretty common
    // this could be any other ports that is whitelisted on firebase
  } else {
    // putting this here just incase if I want a local app for mobile later
    // however, apple store is quite expensive
    // and android developer is broken for me
    // soo.....

    params = const GoogleSignInParams(
      scopes: ['email', 'profile'],
    );
  }
  return GoogleSignIn(params: params);
});

/// the link to AuthService, my all in one authentication file
final authServiceProvider = Provider<AuthService>((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthService(googleSignIn);
});

/// Auth data syncing + a data listener after login

final authStateControllerProvider = Provider((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  final authService = ref.watch(authServiceProvider);
  final syncService = ref.watch(firebaseSyncProvider);
  final hiveRepo = ref.watch(hiveRepositoryProvider);

  // check all the loggin state
  final sub = googleSignIn.authenticationState.listen((credentials) async {
    try {
      if (credentials != null) {
        // sign in to firebase if the user logged in
        final user =
            await authService.signInToFirebaseWithCredentials(credentials);
        if (user != null) {
          // override the local data with the firebase ones
          await syncService.pullAllData();

          // start real-time syncing between local and firebase
          syncService.startRealtimeListeners();
        }
      } else {
        // stop the listener for the continues sync to prevent leaks
        syncService.stopRealtimeListeners();

        // it will clear all entries after logout for now, we will see if people like it or not
        await hiveRepo.clearAllBoxes();
      }
    } catch (e) {
      // incase something goes wrong
      printToConsole(e.toString());
    }
  });

  // displose the subscription to listening firebase
  ref.onDispose(() => sub.cancel());
});


/// just tells the ui if we are signed in or not
final authStateProvider = StreamProvider<User?>((ref) {
  ref.watch(authStateControllerProvider);
  return ref.watch(authServiceProvider).authStateChanges;
});
