import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/main_page/chart_panel.dart';
import '../widgets/main_page/user_info.dart';
import '../widgets/main_page/menu.dart';
import '../../../../responsive.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Main Panel (2/3 of screen)
              if (!Responsive.isOverFlow(context))
                Expanded(
                  flex: 7,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: const MainPanel(),
                  ),
                ),
              // Right sidebar (1/3 of screen)
              if (!Responsive.isOverFlow(context))
                Expanded(
                  flex: 4,
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
                        flex: 4,
                        child: NavigationMenu(
                          onNavigate: (route) => context.pushNamed(route),
                        ),
                      ),
                    ],
                  ),
                ),
              if (Responsive.isOverFlow(context))
                SingleChildScrollView(
                        child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: screenSize.height * 0.7,
                          maxWidth: screenSize.width - 32),
                      child: MainPanel(),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 150, maxWidth: screenSize.width - 32),
                      child: InfoText(),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: screenSize.height * 0.5,
                          maxWidth: screenSize.width - 32),
                      child: NavigationMenu(
                        onNavigate: (route) => context.pushNamed(route),
                      ),
                    )
                  ],
                ))
            ],
          ),
        ),
      ),
    );
  }
}
