import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/display_page/stat_card.dart';

import '../../../../../core/provider/task.dart';

class SummarySection extends ConsumerWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalGoals = ref.watch(totalGoalsProvider);
    final completedToday = ref.watch(tasksCompletedTodayProvider);
    final longestStreak = ref.watch(longestStreakProvider);
    return Row(
      children: [
        StatCard(
          title: 'Total Goals',
          value: totalGoals.toString(),
          icon: Icons.flag,
        ),
        const SizedBox(width: 16),
        StatCard(
          title: 'Completed Today',
          value: completedToday.toString(),
          icon: Icons.check_circle,
        ),
        const SizedBox(width: 16),
        StatCard(
          title: 'Longest Streak',
          value: '${longestStreak}d',
          icon: Icons.local_fire_department,
        ),
      ],
    );
  }
}
