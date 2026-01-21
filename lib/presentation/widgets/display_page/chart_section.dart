/// This file defines the ChartSection widget.
/// It displays a bar chart visualizing the user's task completion
/// progress over the past seven days using the `fl_chart` package and Riverpod for state management.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/provider/task.dart';
import '../../../../../../core/data/util.dart';

/// A widget that displays the weekly task completion data in a bar chart.
class ChartSection extends ConsumerWidget {
  const ChartSection({super.key});

  /// Converts an integer representing the day of the week (1 for Monday, 7 for Sunday)
  /// into a short, one or two-letter string abbreviation.
  String _getShortWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'Th';
      case 5:
        return 'F';
      case 6:
        return 'Sa';
      case 7:
        return 'Su';
      default:
        return '';
    }
  }

  /// Builds the widget tree for the chart section.
  ///
  /// This method watches the [weeklyCompletionsProvider] to asynchronously fetch
  /// task completion data. It then uses a [BarChart] to display this data,
  /// handling loading and error states appropriately.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the asynchronous state of the weekly completions data.
    final weeklyDataAsync = ref.watch(weeklyCompletionsProvider);

    return ConstrainedBox(
      // Ensure the chart has a minimum height to avoid layout issues.
      constraints: const BoxConstraints(minHeight: 300),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart title.
              Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              // Asynchronously handle the data states: loading, error, or data loaded.
              weeklyDataAsync.when(
                data: (weeklyData) {
                  return SizedBox(
                    height: 200,
                    // The main chart widget from the fl_chart package.
                    child: BarChart(
                      BarChartData(
                        barTouchData: BarTouchData(
                            enabled: true), // Enable touch interactions.
                        // Configure the titles for each axis.
                        titlesData: FlTitlesData(
                          // Bottom (X-axis) titles configuration.
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final now = DateUtil.now();
                                // Calculate the specific date for each bar based on its index.
                                final targetDate = now.subtract(
                                    Duration(days: 6 - value.toInt()));
                                // Get the abbreviated day name (e.g., 'M' for Monday).
                                final dayName =
                                    _getShortWeekday(targetDate.weekday);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    dayName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Left (Y-axis) titles configuration.
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize:
                                  40, // Allocate space for Y-axis labels.
                              getTitlesWidget: (value, meta) {
                                // Display integer values on the Y-axis.
                                return Text('${value.toInt()}');
                              },
                            ),
                          ),
                          // Hide top and right titles for a cleaner look.
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        // Hide the chart border.
                        borderData: FlBorderData(show: false),
                        // Map the list of weekly data into BarChartGroupData for rendering.
                        barGroups: weeklyData.asMap().entries.map((e) {
                          final index = e.key;
                          final daily = e.value;
                          return BarChartGroupData(
                            x: index, // The x-axis index for this bar group.
                            barRods: [
                              // Define the visual properties of a single bar.
                              BarChartRodData(
                                toY: daily.count
                                    .toDouble(), // Set bar height from task count.
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Bar color.
                                width: 64, // Bar width.
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        // Hide the background grid lines.
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  );
                },
                // Show a loading indicator while data is being fetched.
                loading: () => const Center(child: CircularProgressIndicator()),
                // Show an error message if the data fetch fails.
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: 16),
              // Chart legend section.
              Center(
                child: Wrap(
                  spacing: 24,
                  children: [
                    _buildLegend(
                      context,
                      color: Theme.of(context).colorScheme.primary,
                      text: 'Tasks Completed',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A helper widget to build a single legend item.
  /// It consists of a colored square followed by a text label.
  Widget _buildLegend(BuildContext context,
      {required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
