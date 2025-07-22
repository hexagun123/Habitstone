// display_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streak/features/main/presentation/widgets/display_page/summary_section.dart';
import '../widgets/display_page/chart_section.dart';
import '../widgets/display_page/goal_list.dart';
import '../widgets/display_page/task_list.dart';

class DisplayPage extends ConsumerWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Lists'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const SummarySection(),
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
