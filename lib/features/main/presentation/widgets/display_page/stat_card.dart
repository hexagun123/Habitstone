// features/main/presentation/widgets/display_page/stat_card.dart
// This file defines the `StatCard` widget, a reusable UI component designed
// to display a single piece of statistical information in a visually appealing
// and consistent manner across the application.

import 'package:flutter/material.dart';

/// A reusable card widget for displaying a single statistic.
///
/// This widget is designed to be a flexible and visually consistent way to
/// show key data points. It takes a title, a value, and an icon, and arranges
/// them in a styled container. It is intended to be used within a `Row` and
/// is wrapped in an `Expanded` widget to ensure it fills available space evenly
/// with other `StatCard`s.
class StatCard extends StatelessWidget {
  /// The descriptive label for the statistic (e.g., "Total Goals").
  final String title;

  /// The numerical or string value of the statistic (e.g., "15" or "3d").
  final String value;

  /// The icon that visually represents the statistic.
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // The Expanded widget allows the card to flexibly occupy space within a Row.
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // A subtle background color derived from the theme's primary color with low opacity.
          color: Theme.of(context).colorScheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        // A Column arranges the icon, value, and title vertically.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The main icon representing the statistic.
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),

            // The large, prominent value of the statistic.
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),

            // The smaller, descriptive title for the statistic.
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    // A muted color to de-emphasize the title compared to the value.
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(178),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
