import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/provider/goal.dart';
import '../../../../../core/model/goal.dart';

class MainPanel extends ConsumerWidget {
  const MainPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'Chart Placeholder',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create at least 3 goals to see the radar chart',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                ),
          ),
        ],
      ),
    );
  }

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
          ...goals.map((goal) => _buildGoalStreakItem(goal, context)),
        ],
      ),
    );
  }

  Widget _buildGoalStreakItem(Goal goal, BuildContext context) {
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

  Widget _buildRadarChart(List<Goal> goals, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate max streak for scaling
    final maxStreak =
        goals.fold(0, (max, goal) => goal.streak > max ? goal.streak : max);
    final maxValue = maxStreak > 5 ? maxStreak.toDouble() : 5.0;

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: goals
                .map((goal) => RadarEntry(value: goal.streak.toDouble()))
                .toList(),
            fillColor: colorScheme.primary.withOpacity(0.3),
            borderColor: colorScheme.primary,
            borderWidth: 2,
          ),
        ],
        radarBorderData: BorderSide(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        gridBorderData: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        tickBorderData: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        radarShape: RadarShape.polygon,
        titlePositionPercentageOffset: 0.15,
        getTitle: (index, angle) {
          return RadarChartTitle(
            text: goals[index].title,
            positionPercentageOffset: 0.1,
          );
        },
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        tickCount: (maxValue / 5).round(),
        ticksTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 10,
        ),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }
}
