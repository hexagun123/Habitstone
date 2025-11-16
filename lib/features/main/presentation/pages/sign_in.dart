/// This file defines the SignInScreen, which provides the user interface
/// for authenticating with a Google account. It utilizes Riverpod for state
/// management and the `google_sign_in_all_platforms` package for the authentication flow.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../../../../core/provider/auth.dart';

/// A screen that allows users to sign in using their Google account.
///
/// It displays an informational message and a dedicated Google Sign-In button.
/// The screen includes custom back navigation logic to handle different routing scenarios.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  /// Builds the user interface for the sign-in screen.
  ///
  /// This method constructs the screen's layout, including an app bar with
  /// a robust back button and a centered body containing the sign-in prompt
  /// and the Google Sign-In button.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the googleSignInProvider to get the Google Sign-In client instance.
    final googleSignIn = ref.watch(googleSignInProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        // A custom back button to ensure correct navigation with GoRouter.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Check if it's possible to pop the current route.
            if (context.canPop()) {
              context.pop();
            } else {
              // If not, navigate to the main screen as a fallback.
              context.goNamed('main');
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Informational text explaining the benefit of signing in.
            const Text(
              'Sign in to sync your habits and streaks.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // The Google Sign-In button provided by the package.
            SizedBox(
              height: 50,
              child: googleSignIn.signInButton(
                // Configuration for the button's appearance and behavior.
                config: const GSIAPButtonConfig(
                  uiConfig: GSIAPButtonUiConfig(
                    theme: GSIAPButtonTheme.filledBlue, // Visual theme.
                    type: GSIAPButtonType
                        .standard, // Button type with icon and text.
                    size: GSIAPButtonSize.large, // Size of the button.
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
