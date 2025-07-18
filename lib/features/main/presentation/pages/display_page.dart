// Update display_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/display_page/chart_section.dart';
import '../widgets/display_page/task_list.dart'; // Add this import

class DisplayPage extends ConsumerWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: const DisplayContent(),
    );
  }
}

class DisplayContent extends ConsumerWidget {
  const DisplayContent({super.key});
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: Column(
        children: [
          const ChartSection(),
          const SizedBox(height: 24),
          const TaskList(), // Add the TaskList widget here
        ],
      ),
    );
  }
}
