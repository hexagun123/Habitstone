// lib/core/config/environment.dart (or any path you prefer)

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class Environment {
  /// The OAuth Client ID for the Web application.
  static const webClientId = String.fromEnvironment('WEB_CLIENT_ID');

  /// The OAuth Client ID for the Desktop application (Windows, macOS, Linux).
  static const desktopClientId = String.fromEnvironment('DESKTOP_CLIENT_ID');

  /// The OAuth Client Secret for the Desktop application.
  static const desktopClientSecret = String.fromEnvironment('DESKTOP_CLIENT_SECRET');

  /// A helper method to perform a runtime check and provide a clear error
  /// if the required environment variables were not provided during the build.
  static void validate() {
    if (kIsWeb) {
      assert(
        webClientId.isNotEmpty,
        '--dart-define=WEB_CLIENT_ID is not set. Please provide it during the build or in launch.json.',
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      assert(
        desktopClientId.isNotEmpty,
        '--dart-define=DESKTOP_CLIENT_ID is not set. Please provide it during the build or in launch.json.',
      );
      assert(
        desktopClientSecret.isNotEmpty,
        '--dart-define=DESKTOP_CLIENT_SECRET is not set. Please provide it during the build or in launch.json.',
      );
    }
  }
}