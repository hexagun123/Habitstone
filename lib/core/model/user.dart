/// This file defines the application's custom user model.
/// It provides a simplified and decoupled representation of a user,
/// abstracting away the specifics of the Firebase `User` object.

import 'package:firebase_auth/firebase_auth.dart';

/// Represents a user within the application.
///
/// This class is used to store essential user information in a clean,
/// app-specific format, independent of the authentication provider.
class AppUser {
  /// The unique identifier for the user, typically from the auth provider.
  final String uid;

  /// The user's email address, which may be null.
  final String? email;

  /// The user's display name, which may be null.
  final String? displayName;

  /// Creates an instance of [AppUser].
  AppUser({required this.uid, this.email, this.displayName});

  /// A factory constructor to create an [AppUser] instance from a Firebase [User] object.
  ///
  /// This provides a convenient way to map the data from the authentication
  /// provider to the application's internal user model.
  factory AppUser.fromFirebase(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
