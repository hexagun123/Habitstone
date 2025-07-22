import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/provider/theme.dart';
import '../../../../../core/theme/app_theme.dart';

class NavigationMenu extends ConsumerWidget {
  final Function(String) onNavigate;

  const NavigationMenu({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Navigation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.add_task_outlined,
                    title: 'New goal',
                    onTap: () => onNavigate('new-goal'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.checklist_outlined,
                    title: 'New Task',
                    onTap: () => onNavigate('new-task'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.display_settings_outlined,
                    title: 'My Lists',
                    onTap: () => onNavigate('display'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: getThemeIcon(currentTheme),
                    title: 'Theme: ${AppTheme.getThemeName(currentTheme)}',
                    onTap: () {
                      final nextTheme = getNextTheme(currentTheme);
                      ref.read(themeProvider.notifier).setTheme(nextTheme);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
