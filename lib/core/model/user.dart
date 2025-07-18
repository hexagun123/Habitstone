import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;

  AppUser({required this.uid, this.email, this.displayName});

  factory AppUser.fromFirebase(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}