import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import '../../../../core/provider/auth.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleSignIn = ref.watch(googleSignInProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        // Add a standard back button that works with GoRouter
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // This will navigate to the previous screen in the stack
            if (context.canPop()) {
              context.pop();
            } else {
              // If there's no screen to pop to, go to the main page
              context.goNamed('main');
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign in to sync your habits and streaks.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
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
