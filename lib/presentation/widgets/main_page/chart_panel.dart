// features/main/presentation/widgets/main_page/chart_panel.dart
// The main panel is a radar chart, with stats,

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/model/goal.dart';
import '../../../core/provider/goals.dart';

// A dashboard that is responsive to the amount of goals you have
class MainPanel extends ConsumerWidget {
  const MainPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Goal provider, watch it so everytime it change we change as well
    final goals = ref.watch(goalProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withAlpha(50),
                  ),
                ),
                // The responsive part, stacking terinary operators (if statements are too big to write)
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

  // The helper methods ie: the actural widgets
  // the empty one
  Widget _buildEmptyPlaceholder(BuildContext context) {
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
            'There should be a chart here',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go ahead and add some goals to see it',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
          ),
        ],
      ),
    );
  }

  // A list for 1/2 goals as the radar accepts only from 3 and above
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
          // map iterate the goals for the function inside, so builds the item one by one
          // the spread operator then just seperate them into different items from the list
          ...goals.map((goal) => _buildGoalItem(goal, context)),
        ],
      ),
    );
  }

  // helper function for above for a single goal
  Widget _buildGoalItem(Goal goal, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Text(
            goal.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  // Big boi radar chart
  Widget _buildRadarChart(List<Goal> goals, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine the max for the chart scale
    // fold iterate through the goals to determine the maximum streak (compressed for loop)
    final maxStreak =
        goals.fold(0, (max, goal) => goal.streak > max ? goal.streak : max);

    // make the max cap at 5, if it is smaller just make it five so we dont have a size one graph
    final maxValue = maxStreak > 5 ? maxStreak.toDouble() : 5.0;

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            // map goal to data entries, then make it into a list
            dataEntries: goals
                .map((goal) => RadarEntry(value: goal.streak.toDouble()))
                .toList(),
            fillColor: colorScheme.primary.withAlpha(77),
            borderColor: colorScheme.primary,
            borderWidth: 2,
          ),
        ],
        radarShape: RadarShape.polygon, // polygon
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
        tickCount: (maxValue + 1).ceil(), // Number of concentric grid lines.
        ticksTextStyle: TextStyle(
          color: colorScheme.onSurface.withAlpha(100), // (70%)
          fontSize: 10,
        ),
        tickBorderData: BorderSide(
          color: colorScheme.outline.withAlpha(51), // (20%)
          width: 1,
        ),
        gridBorderData: BorderSide(
          color: colorScheme.outline.withAlpha(100), // (20%)
          width: 1,
        ),
        radarBorderData: BorderSide(
            color: colorScheme.outline.withAlpha(150), // (30%)
            width: 2),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}
