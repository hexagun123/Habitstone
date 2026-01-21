// features/main/presentation/widgets/display_page/summary_section.dart
// This file defines the `SummarySection` widget, a key component of the display
// or dashboard screen. It presents a high-level overview of the user's progress
// by displaying essential statistics in a clear, card-based format.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/provider/task.dart';
import 'stat_card.dart';

/// A widget that displays a row of key statistics about the user's progress.
///
/// This [ConsumerWidget] subscribes to several providers to fetch and display
/// metrics such as the total number of goals, tasks completed today, and the
/// user's longest streak. It arranges this data into a horizontal layout
/// using custom [StatCard] widgets for a consistent look and feel.
class SummarySection extends ConsumerWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch various providers to get the latest statistical data.
    // The widget will automatically rebuild if any of these values change.
    final totalGoals = ref.watch(totalGoalsProvider);
    final completedToday = ref.watch(tasksCompletedTodayProvider);
    final longestStreak = ref.watch(longestStreakProvider);

    // Arrange the statistic cards in a horizontal row.
    return Row(
      children: [
        // Card displaying the total number of goals created by the user.
        StatCard(
          title: 'Total Goals',
          value: totalGoals.toString(),
          icon: Icons.flag,
        ),
        const SizedBox(width: 16), // Spacer between cards.

        // Card displaying the count of tasks completed on the current day.
        StatCard(
          title: 'Completed Today',
          value: completedToday.toString(),
          icon: Icons.check_circle,
        ),
        const SizedBox(width: 16), // Spacer between cards.

        // Card displaying the user's longest goal streak in days.
        StatCard(
          title: 'Longest Streak',
          value: '${longestStreak}d', // Append 'd' for days.
          icon: Icons.local_fire_department,
        ),
      ],
    );
  }
}