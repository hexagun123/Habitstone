// features/main/presentation/widgets/main_page/menu.dart
// This file defines the `NavigationMenu` widget, a primary UI component for
// navigating between the main sections of the application. It is integrated
// with the `ShowcaseView` package to provide an interactive tutorial for
// first-time users.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/data/showcase_key.dart';

/// A navigation widget displayed as a card on the main screen.
///
/// This widget presents a list of tappable items that allow the user to
/// navigate to different features like creating goals, tasks, rewards, or
/// viewing their lists. It uses an `onNavigate` callback to delegate the
//  actual navigation logic to its parent widget.
class NavigationMenu extends ConsumerWidget {
  /// A callback function that is invoked with a route name when a menu
  /// item is tapped.
  final Function(String) onNavigate;

  const NavigationMenu({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Title ---
            Text(
              'Navigation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // --- Scrollable Menu Items ---
            Expanded(
              child: ListView(
                children: [
                  // Each navigation item is wrapped in a `Showcase` widget. This
                  // integrates it into the app's interactive tutorial, highlighting
                  // the feature and explaining its purpose to new users.
                  Showcase(
                    key: six, // Unique key for this tutorial step.
                    title: "New Goal",
                    description:
                        "Set broad, overarching goals you want to work towards.",
                    child: _buildMenuItem(
                      context,
                      icon: Icons.add_task_outlined,
                      title: 'New Goal',
                      onTap: () => onNavigate('new-goal'),
                    ),
                  ),
                  Showcase(
                    key: seven,
                    title: "New Task",
                    description:
                        "Create specific, actionable tasks to achieve your goals.",
                    child: _buildMenuItem(
                      context,
                      icon: Icons.checklist_outlined,
                      title: 'New Task',
                      onTap: () => onNavigate('new-task'),
                    ),
                  ),
                  Showcase(
                    key: nine,
                    title: "New Reward",
                    description:
                        "Define rewards for yourself for making progress.",
                    child: _buildMenuItem(
                      context,
                      icon: Icons.toys,
                      title: 'New Reward',
                      onTap: () => onNavigate('new-reward'),
                    ),
                  ),
                  Showcase(
                    key: eight,
                    title: "My Lists",
                    description:
                        "View, manage, and complete your goals and tasks.",
                    child: _buildMenuItem(
                      context,
                      icon: Icons.display_settings_outlined,
                      title: 'My Lists',
                      onTap: () => onNavigate('display'),
                    ),
                  ),

                  // Visual separator for clarity.
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  Showcase(
                    key: ten,
                    title: "Settings",
                    description:
                        "Customize app settings or retake this tutorial. Next: Tap 'New Goal'!",
                    child: _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => onNavigate('setting'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A private helper method to build a consistent menu item.
  ///
  /// This encapsulates the styling and layout for each navigation row,
  /// ensuring a uniform look and feel across the menu. Using a helper method
  /// reduces code duplication and improves maintainability.
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // InkWell provides the material splash effect on tap.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // The icon for the menu item.
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
            ),
            const SizedBox(width: 12),
            // The text label for the menu item.
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