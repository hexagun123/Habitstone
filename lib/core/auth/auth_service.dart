// core/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn;

  AuthService(this._googleSignIn);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Initiates the sign-in flow. Used by desktop or other non-button flows.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInCredentials? credentials = await _googleSignIn.signIn();
      if (credentials == null) return null;
      
      // After getting credentials, delegate to the new method
      return await signInToFirebaseWithCredentials(credentials);
    } catch (e) {
      print("Sign-In Flow Error: $e");
      return null;
    }
  }

  /// --- NEW METHOD ---
  /// Takes credentials from an external source (like the web button's callback)
  /// and signs the user into Firebase.
  Future<User?> signInToFirebaseWithCredentials(GoogleSignInCredentials credentials) async {
    try {
      final String? idToken = credentials.idToken;
      if (idToken == null) {
        print('AuthService: Missing Google ID Token from credentials.');
        return null;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: credentials.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print("AuthService: Successfully signed in to Firebase!");
      return userCredential.user;
    } catch (e) {
      print("AuthService: 🛑 Error signing into Firebase with credentials: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Sign-Out Error: $e");
    }
  }
}