// features/main/presentation/widgets/main_page/chart_panel.dart
// This file contains the `MainPanel` widget, a central component of the dashboard.
// Its primary function is to provide a visual representation of the user's
// progress across their goals, adapting its display based on the amount of
// available data.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/model/goal.dart';
import '../../../../../core/provider/goal.dart';

/// A dashboard widget that visualizes the user's goal progress.
///
/// This widget listens to the `goalProvider` to get the current list of goals.
/// It dynamically chooses the best visualization:
/// - An empty state placeholder if there are no goals.
/// - A simple list of streaks if there are 1 or 2 goals.
/// - A detailed radar chart if there are 3 or more goals.
class MainPanel extends ConsumerWidget {
  const MainPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the goalProvider to get the list of goals and rebuild on changes.
    final goals = ref.watch(goalProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Panel Header ---
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // --- Visualization Area ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  // A subtle background and border for the chart container.
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withAlpha(50),
                  ),
                ),
                // Conditionally render the appropriate visualization based on goal count.
                child: goals.isEmpty
                    ? _buildEmptyPlaceholder(context)
                    : goals.length < 3
                        ? _buildAlternativeVisualization(goals, context)
                        : _buildRadarChart(goals, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Building Helper Methods ---

  /// Builds a placeholder widget for when there are no goals to display.
  ///
  /// This provides a clear, user-friendly message guiding the user to create
  /// goals to activate the chart functionality.
  Widget _buildEmptyPlaceholder(BuildContext context) {
    // A centered column for the placeholder content.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chart Placeholder',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // Use a muted color for placeholder text.
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create at least 3 goals to see the radar chart',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
          ),
        ],
      ),
    );
  }

  /// Builds a simple list-based visualization for 1 or 2 goals.
  ///
  /// A radar chart is not effective with fewer than three data points, so this
  /// serves as a more appropriate and readable fallback.
  Widget _buildAlternativeVisualization(
      List<Goal> goals, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Goal Streaks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          // Map each goal to its own streak item widget.
          ...goals.map((goal) => _buildGoalStreakItem(goal, context)),
        ],
      ),
    );
  }

  /// Helper widget to display a single goal's title and streak count.
  Widget _buildGoalStreakItem(Goal goal, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A circular container to highlight the streak number.
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              goal.streak.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // The title of the goal.
          Text(
            goal.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Builds and configures the radar chart for 3 or more goals.
  ///
  /// This chart provides a powerful at-a-glance view of the user's progress
  /// balance across their different goals, using the streak count as the value
  /// for each axis.
  Widget _buildRadarChart(List<Goal> goals, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine the maximum value for the chart's scale. This ensures all
    // data points are visible. A minimum value of 5 is used to prevent the
    // chart from looking empty with very low streak counts.
    final maxStreak =
        goals.fold(0, (max, goal) => goal.streak > max ? goal.streak : max);
    final maxValue = maxStreak > 5 ? maxStreak.toDouble() : 5.0;

    return RadarChart(
      RadarChartData(
        // --- Data & Styling ---
        dataSets: [
          RadarDataSet(
            // Map each goal's streak to a data entry for the chart.
            dataEntries: goals
                .map((goal) => RadarEntry(value: goal.streak.toDouble()))
                .toList(),
            fillColor: colorScheme.primary.withAlpha(77), // Area fill (30%)
            borderColor: colorScheme.primary, // Outline of the data shape
            borderWidth: 2,
          ),
        ],
        // --- Chart Structure & Labels ---
        radarShape: RadarShape.polygon, // Use straight lines between points.
        getTitle: (index, angle) {
          // Dynamically provide the title for each axis from the goal list.
          return RadarChartTitle(
            text: goals[index].title,
            // Adjust position to avoid overlap with the chart.
            positionPercentageOffset: 0.1,
          );
        },
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        // --- Grid & Ticks ---
        tickCount: (maxValue / 5).ceil(), // Number of concentric grid lines.
        ticksTextStyle: TextStyle(
          color: colorScheme.onSurface.withAlpha(178), // (70%)
          fontSize: 10,
        ),
        gridBorderData: BorderSide(
          color: colorScheme.outline.withAlpha(51), // (20%)
          width: 1,
        ),
        radarBorderData: BorderSide(
          color: colorScheme.outline.withAlpha(77), // (30%)
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}
