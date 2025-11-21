// features/main/presentation/widgets/main_page/menu.dart
// navigation menu widget, a section of the main_page, 
// I put it here because putting it in a single file would become too massive.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/data/showcase_key.dart';

// navigation menu itself
class NavigationMenu extends ConsumerWidget {
  // A callback function, basically either push or pushnamed that is fed into this class
  final Function(String) onNavigate;

  const NavigationMenu({
    super.key,
    required this.onNavigate,
  }); // constructor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Text(
              'Navigation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Items
            Expanded(
              child: ListView(
                children: [
                  // Showcase for each item
                  Showcase(
                    key: six, // a key for reference
                    title: title_six, // a title from the const list
                    description: description_six, // a description from the const list
                    child: _buildMenuItem(
                      context,
                      icon: Icons.add_task_outlined,
                      title: 'New Goal',
                      onTap: () => onNavigate('new-goal'), // the call backfunction
                    ),
                  ),
                  Showcase(
                    key: seven,
                    title: title_seven,
                    description: description_seven,
                    child: _buildMenuItem(
                      context,
                      icon: Icons.checklist_outlined,
                      title: 'New Task',
                      onTap: () => onNavigate('new-task'),
                    ),
                  ),
                  Showcase(
                    key: eight,
                    title: title_eight,
                    description: description_eight,
                    child: _buildMenuItem(
                      context,
                      icon: Icons.toys,
                      title: 'New Reward',
                      onTap: () => onNavigate('new-reward'),
                    ),
                  ),
                  Showcase(
                    key: nine,
                    title: title_nine,
                    description: description_nine,
                    child: _buildMenuItem(
                      context,
                      icon: Icons.display_settings_outlined,
                      title: 'My Lists',
                      onTap: () => onNavigate('display'),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(), // a massive line like this: ______________
                  const SizedBox(height: 16),

                  Showcase(
                    key: ten,
                    title: title_ten,
                    description: description_ten,
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

// some settings for each menu item
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap, // the call back, technically because I used this template everywhere for all sorts of lists it is not dedicated
  }) {
    // fancy animation button
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
