// display_page.dart
// This file defines the layout for a comprehensive display screen.
// It aggregates and presents various user-specific data sections such as
// summaries, charts, goals, tasks, and rewards in a single scrollable view.
// It also integrates with ShowcaseView to provide a guided tour for new users.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streak/features/main/presentation/widgets/display_page/summary_section.dart';
import '../widgets/display_page/chart_section.dart';
import '../widgets/display_page/goal_list.dart';
import '../widgets/display_page/task_list/task_list.dart';
import '../widgets/display_page/reward_list.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/data/showcase_key.dart';

/// A widget that displays a collection of user data panels.
///
/// This widget uses a `SingleChildScrollView` to present multiple sections
/// vertically, ensuring the content is accessible even on smaller screens.
/// Each section is wrapped with a `Showcase` widget for the tutorial.
class DisplayPage extends ConsumerWidget {
  const DisplayPage({super.key});

  /// Builds the user interface for the display page.
  ///
  /// It constructs a `Scaffold` containing a scrollable `Column` of different
  /// information sections. Each section provides a different view of the user's
  /// data, such as progress summaries and lists of goals, rewards, and tasks.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Lists'),
        ),
        body: SingleChildScrollView(
          // Provides padding for the content within the scroll view
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 16), // Vertical spacing
              // Displays a quick summary of user accomplishments.
              Showcase(
                  key: nineteen,
                  title: "Summary",
                  description: "Quick summary of what you have accomplished",
                  child: SummarySection()),
              const SizedBox(height: 24), // Vertical spacing
              // Visualizes user achievement data in a chart format.
              Showcase(
                  key: twenty,
                  title: "Chart",
                  description:
                      "Another chart for you to visualise the achievement",
                  child: ChartSection()),
              const SizedBox(height: 24), // Vertical spacing
              // Lists the user's goals and allows for their manipulation.
              Showcase(
                key: twentyOne,
                title: "Goals",
                description:
                    "A description of what you've setted for your goal, and a place to manipulate them",
                child: GoalList(),
              ),
              const SizedBox(height: 24), // Vertical spacing
              // Lists the available rewards and allows for their deletion.
              Showcase(
                key: twentyTwo,
                title: "Reward",
                description:
                    "A place for you to see the different rewards and delete them",
                child: RewardList(),
              ),
              const SizedBox(height: 24), // Vertical spacing
              // Manages user tasks, allowing for creation, completion, and manipulation.
              Showcase(
                key: twentyThree,
                title: "Tasks",
                description:
                    "A place for you to add task to complete, and manipulate the tasks. You can assign task in two ways: manually or randomly",
                child: TaskList(),
              ),
            ],
          ),
        ));
  }
}
