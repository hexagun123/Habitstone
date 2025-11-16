// lib/features/main/presentation/pages/setting.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../core/data/showcase_key.dart';
import '../../../../core/provider/setting.dart';
import '../../../../core/provider/theme.dart';
import '../../../../core/theme/app_theme.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentSettings = ref.watch(settingsProvider);
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
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Showcase(
                      key: twentySix,
                      title: "Theme",
                      description:
                          "Welcome to the settings! You could change the theme of the app by clicking on this button.",
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
                    Showcase(
                      key: twentySeven,
                      title: "Weight",
                      description:
                          "The special attribute that I mentioned in randomly generating tasks, if you would like the easy tasks first, reduce the weight, if you would like the hard tasks first, increase the weight.",
                      child: _buildWeightSlider(
                        context,
                        currentWeight: currentSettings.weight,
                        onWeightChanged: (weight) {
                          settingsNotifier.updateWeight(weight);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Showcase(
                      key: twentyEight,
                      title: "Tutorial",
                      description:
                          "You have reached the end of the tutorial. If you want to review it again, just click this button.",
                      child: _buildMenuItem(
                        context,
                        icon: Icons.school_outlined,
                        title: 'Restart Tutorial',
                        onTap: () {
                          // Navigate back to the main page.
                          GoRouter.of(context).go('/');

                          // After a short delay to allow for the page transition,
                          // start the showcase on the main page.
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
          Slider(
            value: currentWeight.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: currentWeight.toString(),
            onChanged: (value) {
              onWeightChanged(value.toInt());
            },
          ),
          Text(
            'Adjust weight setting (1-10)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
          ),
        ],
      ),
    );
  }
}
