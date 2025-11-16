// display_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streak/features/main/presentation/widgets/display_page/summary_section.dart';
import '../widgets/display_page/chart_section.dart';
import '../widgets/display_page/goal_list.dart';
import '../widgets/display_page/task_list/task_list.dart';
import '../widgets/display_page/reward_list.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/data/showcase_key.dart';

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
              Showcase(key:nineteen,title:"Summary",description:"Quick summary of what you have accomplished",child:SummarySection()),
              const SizedBox(height: 24),
              Showcase(key:twenty,title:"Chart",description:"Another chart for you to visualise the achievement",child:ChartSection()),
              const SizedBox(height: 24),
              Showcase(key:twentyOne,title:"Goals",description:"A description of what you've setted for your goal, and a place to manipulate them",child:GoalList(),),
              const SizedBox(height: 24),
              Showcase(key:twentyTwo,title:"Reward",description:"A place for you to see the different rewards and delete them" ,child:RewardList(),),
              const SizedBox(height: 24),
              Showcase(key:twentyThree,title:"Tasks",description:"A place for you to add task to complete, and manipulate the tasks. You can assign task in two ways: manually or randomly" ,child:TaskList(),),
            ],
          ),
        ));
  }
}
