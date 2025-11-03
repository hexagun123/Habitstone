import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../../../../core/provider/auth.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the GoogleSignIn instance from its provider
    final googleSignIn = ref.watch(googleSignInProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign in to sync your habits and streaks.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // --- THE SIMPLIFIED BUTTON ---
            // We removed the onSignIn callback. This button's only purpose
            // is to trigger the sign-in flow. The result will be caught
            // by our new `authStateControllerProvider`.
            SizedBox(
              height: 50,
              child: googleSignIn.signInButton(
                config: const GSIAPButtonConfig(
                  uiConfig: GSIAPButtonUiConfig(
                    theme: GSIAPButtonTheme.filledBlue,
                    type: GSIAPButtonType.standard,
                    size: GSIAPButtonSize.large,
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
