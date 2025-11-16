// main_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import '../widgets/main_page/chart_panel.dart';
import '../widgets/main_page/user_info.dart';
import '../widgets/main_page/menu.dart';
import '../../../../responsive.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/data/showcase_key.dart';

// 1. Convert to a ConsumerStatefulWidget
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
    // 2. The logic now lives here, where it has access to the widget's context
    // and runs only after the widget is in the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  void _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool("launch") ?? true;

    if (isFirstLaunch && mounted) {
      // 3. Start the showcase using the correct API and the widget's context.
      ShowcaseView.get().startShowCase(
          [one, two, three, four, five, six, seven, eight, nine, ten]);
      await prefs.setBool("launch", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // 4. The Showcase widget itself is correctly placed around the Scaffold.
    return Showcase(
      key: one,
      title: "Welcome to HabitStone!",
      description:
          "This is your main dashboard where you can see your progress.",
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (!Responsive.isOverFlow(context))
                  Expanded(
                    flex: 7,
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Showcase(
                          key: two,
                          title: "statistics",
                          description:
                              "This is where you can see your goals in the format of graphs",
                          child: const MainPanel()),
                    ),
                  ),
                if (!Responsive.isOverFlow(context))
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Showcase(
                              key: three,
                              title: "Information",
                              description:
                                  "This is the place for authentication and your user information",
                              child: InfoText(),
                            )),
                        const SizedBox(height: 16),
                        Expanded(
                          flex: 4,
                          child: Showcase(
                              key: four,
                              title: "Navigation",
                              description:
                                  "This is the menu for navigation between features",
                              child: NavigationMenu(
                                onNavigate: (route) => context.pushNamed(route),
                              )),
                        ),
                      ],
                    ),
                  ),
                if (Responsive.isOverFlow(context))
                  SingleChildScrollView(
                      child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: screenSize.height * 0.7,
                            maxWidth: screenSize.width - 32),
                        child: Showcase(
                            key: two,
                            title: "statistics",
                            description:
                                "This is where you can see your goals in the format of graphs",
                            child: const MainPanel()),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 150, maxWidth: screenSize.width - 32),
                        child: Showcase(
                          key: three,
                          title: "Information",
                          description:
                              "This is the place for authentication and your user information",
                          child: InfoText(),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: screenSize.height * 0.5,
                            maxWidth: screenSize.width - 32),
                        child: Showcase(
                            key: four,
                            title: "Navigation",
                            description:
                                "This is the menu for navigation between features",
                            child: NavigationMenu(
                              onNavigate: (route) => context.pushNamed(route),
                            )),
                      )
                    ],
                  ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
