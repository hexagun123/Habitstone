import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../../core/data/showcase_key.dart';

class NavigationMenu extends ConsumerWidget {
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
                  Showcase(
                      key: six,
                      title: "Goal",
                      description:
                          "This place is for setting up a new goal, try to make these goals something broad, general, that you want to work upon to maintain a habit of.",
                      child: _buildMenuItem(
                        context,
                        icon: Icons.add_task_outlined,
                        title: 'New goal',
                        onTap: () => onNavigate('new-goal'),
                      )),
                  Showcase(
                      key: seven,
                      title: "Task",
                      description:
                          "This place is for creating a new task, try to make them as specific as possible",
                      child: _buildMenuItem(
                        context,
                        icon: Icons.checklist_outlined,
                        title: 'New Task',
                        onTap: () => onNavigate('new-task'),
                      )),

                  Showcase(
                      key: nine,
                      title: "reward",
                      description:
                          "This is the place to set reward for yourself, don't hesitate, you will deserve it!",
                      child: _buildMenuItem(
                        context,
                        icon: Icons.toys,
                        title: 'New Reward',
                        onTap: () => onNavigate('new-reward'),
                      )),
                  Showcase(
                      key: eight,
                      title: "My list",
                      description:
                          "an overview of everything you have done, and the place to assign tasks, complete tasks and to modify other things.",
                      child: _buildMenuItem(
                        context,
                        icon: Icons.display_settings_outlined,
                        title: 'My Lists',
                        onTap: () => onNavigate('display'),
                      )),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  //temp

                  Showcase(
                      key: ten,
                      title: "setting",
                      description:
                          "This is the place to modify the setting, and to take another tutorial! Next step: click on the new-goal button!",
                      child: _buildMenuItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => onNavigate('setting'),
                      )),
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
