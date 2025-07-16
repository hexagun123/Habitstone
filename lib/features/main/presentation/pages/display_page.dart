import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/provider/task.dart';
import '../widgets/display_page/chart_section.dart';
import '../widgets/display_page/stat_card.dart';
import '../widgets/display_page/task_list.dart';
import '../widgets/display_page/summary_section.dart';

class DisplayPage extends ConsumerWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: const DisplayContent(),
    );
  }
}

class DisplayContent extends ConsumerWidget {
  const DisplayContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const ChartSection(),
          const SizedBox(height: 16),
          const SummarySection(),
          const SizedBox(height: 16),
          const TaskList(),
        ],
      ),
    );
  }
}
