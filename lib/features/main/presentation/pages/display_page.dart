// display_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/display_page/stat_card.dart';
import '../widgets/display_page/chart_section.dart';
import '../widgets/display_page/goal_list.dart';
import '../widgets/display_page/task_list.dart';
import '../../../../core/provider/task.dart';

class DisplayPage extends ConsumerWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalGoals = ref.watch(totalGoalsProvider);
    final completedToday = ref.watch(tasksCompletedTodayProvider);
    final longestStreak = ref.watch(longestStreakProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('My Lists'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
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
              ),
              const SizedBox(height: 24),
              const ChartSection(),
              const SizedBox(height: 24),
              const GoalList(),
              const SizedBox(height: 24),
              const TaskList(),
            ],
          ),
        ));
  }
}
