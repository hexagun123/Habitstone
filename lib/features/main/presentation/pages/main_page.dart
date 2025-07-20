import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/main_page/chart_panel.dart';
import '../widgets/main_page/user_info.dart';
import '../widgets/main_page/menu.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Main Panel (2/3 of screen)
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const MainPanel(),
                ),
              ),
              // Right sidebar (1/3 of screen)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Info Text (1/4 of remaining space)
                    const Expanded(
                      flex: 1,
                      child: InfoText(),
                    ),
                    const SizedBox(height: 16),
                    // Navigation Menu (3/4 of remaining space)
                    Expanded(
                      flex: 3,
                      child: NavigationMenu(
                        onNavigate: (route) => context.pushNamed(route),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
