/// This file defines the SettingPage, providing a UI for users to configure
/// application settings like theme, task randomization weight, and to restart the tutorial.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/data/showcase_key.dart';
import '../../core/provider/settings.dart';
import '../../../../../core/provider/theme.dart';
import '../../../../../core/theme/app_theme.dart';

/// A screen that allows the user to modify application settings.
///
/// This `ConsumerWidget` watches theme and settings providers to display current
/// values and provides controls to update them. It also includes an option
/// to restart the app's feature tour.
class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers to get current state and rebuild on change.
    final currentTheme = ref.watch(themeProvider);
    final currentSettings = ref.watch(settingsProvider);
    // Read the notifier to call methods that change the state.
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group settings items within a single Card for a cohesive look.
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // Showcase widget for the "Theme" setting during the tutorial.
                    Showcase(
                      key: twentySix,
                      title: title_twentySix,
                      description: description_twentySix,
                      // Menu item for changing the application theme.
                      child: _buildMenuItem(
                        context,
                        icon: getThemeIcon(currentTheme),
                        title: 'Theme: ${AppTheme.getThemeName(currentTheme)}',
                        onTap: () {
                          final nextTheme = getNextTheme(currentTheme);
                          ref.read(themeProvider.notifier).setTheme(nextTheme);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    // Showcase widget for the "Weight" setting.
                    Showcase(
                      key: twentySeven,
                      title: title_twentySeven,
                      description: description_twentySeven,
                      // Slider for adjusting the task randomization weight.
                      child: _buildWeightSlider(
                        context,
                        currentWeight: currentSettings.weight,
                        onWeightChanged: (weight) {
                          settingsNotifier.updateWeight(weight);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    // Showcase widget for the "Restart Tutorial" button.
                    Showcase(
                      key: twentyEight,
                      title: title_twentyEight,
                      description: description_twentyEight,
                      // Menu item to restart the application tutorial.
                      child: _buildMenuItem(
                        context,
                        icon: Icons.school_outlined,
                        title: 'Restart Tutorial',
                        onTap: () {
                          // Navigate back to the main page.
                          GoRouter.of(context).go('/');
                          // Delay is needed to allow the UI to transition before starting the showcase.
                          Future.delayed(const Duration(milliseconds: 400), () {
                            ShowcaseView.get().startShowCase([
                              one,
                              two,
                              three,
                              four,
                              five,
                              six,
                              seven,
                              eight,
                              nine,
                              ten
                            ]);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to build a consistent menu item with an icon, title, and an onTap callback.
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

  /// A helper widget to build the slider for adjusting the task randomization weight.
  Widget _buildWeightSlider(
    BuildContext context, {
    required int currentWeight,
    required ValueChanged<int> onWeightChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for the slider section.
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
              ),
              const SizedBox(width: 12),
              Text(
                'Weight: $currentWeight',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // The slider control.
          Slider(
            value: currentWeight.toDouble(),
            min: 1,
            max: 10,
            divisions: 9, // Allows for integer steps from 1 to 10.
            label: currentWeight.toString(),
            onChanged: (value) {
              onWeightChanged(value.toInt());
            },
          ),
          // Informational text below the slider.
          Text(
            'Weight above 5 does the tasks with more apparence first, and vice versa',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
          ),
        ],
      ),
    );
  }
}
