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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Responsive(
            mobile: _buildMobileLayout(context),
            tablet: _buildTabletLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
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
          child: _buildRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        // Main Panel (top 70%)
        const Expanded(
          flex: 7,
          child: MainPanel(),
        ),
        const SizedBox(height: 16),
        // Right panel (bottom 30%)
        Expanded(
          flex: 3,
          child: _buildRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Main Panel (top 60%)
        const Expanded(
          flex: 6,
          child: MainPanel(),
        ),
        const SizedBox(height: 16),
        // Right panel (bottom 40%)
        Expanded(
          flex: 4,
          child: _buildRightPanel(context),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Column(
      children: [
        // Info Text
        const Expanded(
          flex: 1,
          child: InfoText(),
        ),
        const SizedBox(height: 16),
        // Navigation Menu
        Expanded(
          flex: 3,
          child: NavigationMenu(
            onNavigate: (route) => context.pushNamed(route),
          ),
        ),
      ],
    );
  }
}
