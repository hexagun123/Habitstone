// lib/core/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService(this._googleSignIn);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print("🛑 ERROR during Google Sign-In process: $error");
    }
  }

  Future<User?> signInToFirebaseWithCredentials(GoogleSignInCredentials credentials) async {
    try {
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: credentials.accessToken,
        idToken: credentials.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("🛑 ERROR signing into Firebase with credentials: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}