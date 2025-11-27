/// AuthService

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

/// A service class that manages all aspects of user authentication.
///
/// This class abstracts the complexities of interacting with Firebase and Google
/// authentication APIs. It provides simple methods to sign in, sign out, and
/// listen to changes in the user's authentication state.
class AuthService {
  final GoogleSignIn _googleSignIn; // The instance for Google Sign-In.
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // The instance for Firebase Auth.

  AuthService(this._googleSignIn);

  /// A stream that notifies listeners about changes in the user's sign-in state.
  ///
  /// Widgets can listen to this stream to reactively update the UI when a user
  /// signs in or out. For example, it can be used to navigate between a login
  /// screen and the main application screen.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Initiates the Google Sign-In flow.
  ///
  /// This method displays the native Google Sign-In UI, allowing the user to
  /// select their account. It handles the initial part of the authentication
  /// process with Google's servers.
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      // Errors during this process are typically due to network issues
      // or the user canceling the sign-in flow.
    }
  }

  /// Signs the user into Firebase using credentials obtained from Google Sign-In.
  ///
  /// After a successful Google sign-in, this method takes the resulting
  /// credentials and exchanges them with Firebase for a Firebase user session.
  /// Returns the authenticated [User] object on success, or `null` on failure.
  Future<User?> signInToFirebaseWithCredentials(
      GoogleSignInCredentials credentials) async {
    try {
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: credentials.accessToken,
        idToken: credentials.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      // This error can occur if the credentials are invalid or expired,
      // or if there's a problem communicating with Firebase servers.
      return null;
    }
  }

  /// Signs the current user out of both Firebase and Google.
  ///
  /// It is crucial to sign out from both services to ensure that the user's
  /// session is fully terminated and they are prompted to sign in again
  /// upon returning to the app.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
