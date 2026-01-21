// main_page.dart
// This file defines the main dashboard screen for the application.
// It serves as the central hub, displaying user statistics, information,
// and navigation options. It also integrates a first-launch tutorial feature.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/main_page/chart_panel.dart';
import '../widgets/main_page/user_info.dart';
import '../widgets/main_page/menu.dart';
import '../../../../../responsive.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../../core/data/showcase_key.dart';

/// A stateful widget that constructs the main page of the application.
/// It utilizes `ConsumerStatefulWidget` for potential integration with Riverpod state management
/// and manages the logic for the initial user tutorial.
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

/// The state management class for [MainPage].
/// It handles the lifecycle of the widget, including initializing the
/// first-launch tutorial sequence after the widget has been built.
class _MainPageState extends ConsumerState<MainPage> {
  /// Initializes the state.
  /// A post-frame callback is scheduled to ensure the `_checkFirstLaunch` method
  /// runs after the initial frame is rendered, which is a requirement for the
  /// showcase view to find its target widgets in the tree.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  /// Checks if this is the user's first time launching the app.
  /// It uses [SharedPreferences] to persist this state. If it is the first launch,
  /// it initiates the tutorial sequence using [ShowcaseView] and then updates
  /// the preference to prevent the tutorial from showing again.
  void _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch =
        prefs.getBool("launch") ?? true; // Default to true if not set

    if (isFirstLaunch && mounted) {
      // Start the tutorial using the predefined global keys
      ShowcaseView.get().startShowCase(
          [one, two, three, four, five, six, seven, eight, nine, ten]);
      // Set the flag to false so the tutorial doesn't run again
      await prefs.setBool("launch", false);
    }
  }

  /// Describes the part of the user interface represented by this widget.
  ///
  /// The build method constructs a responsive layout that adapts to different screen sizes.
  /// On wider screens, it uses a [Row] to display components side-by-side.
  /// On narrower screens ([Responsive.isOverFlow]), it switches to a [SingleChildScrollView]
  /// containing a [Column] to prevent UI overflow. Each major UI component is
  /// wrapped in a [Showcase] widget to be highlighted during the first-launch tutorial.
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // The root of the tutorial showcase
    return Showcase(
      key: one,
      title: title_one,
      description: description_one,
      child: Scaffold(
        body: SafeArea(
          // Provides padding for the entire page content
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Layout for wider screens (e.g., tablets, desktops)
                if (!Responsive.isOverFlow(context))
                  Expanded(
                    flex:
                        7, // Takes up 7 parts of the available horizontal space
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      // Showcase for the main statistics panel
                      child: Showcase(
                          key: two,
                          title: title_two,
                          description: description_two,
                          child: const MainPanel()),
                    ),
                  ),
                // Layout for wider screens (e.g., tablets, desktops)
                if (!Responsive.isOverFlow(context))
                  Expanded(
                    flex:
                        4, // Takes up 4 parts of the available horizontal space
                    child: Column(
                      children: [
                        Expanded(
                            flex:
                                1, // Takes up 1 part of the vertical space in this column
                            // Showcase for the user information area
                            child: Showcase(
                              key: three,
                              title: title_three,
                              description: description_three,
                              child: InfoText(),
                            )),
                        const SizedBox(height: 16), // Vertical spacing
                        Expanded(
                          flex: 4, // Takes up 4 parts of the vertical space
                          // Showcase for the main navigation menu
                          child: Showcase(
                              key: four,
                              title: title_four,
                              description: description_four,
                              child: NavigationMenu(
                                // Navigate to the selected route using go_router
                                onNavigate: (route) => context.pushNamed(route),
                              )),
                        ),
                      ],
                    ),
                  ),
                // Layout for narrower screens (e.g., mobile phones) to prevent overflow
                if (Responsive.isOverFlow(context))
                  SingleChildScrollView(
                      child: Column(
                    children: [
                      // Constrains the size of the main panel on smaller screens
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: screenSize.height * 0.7,
                            maxWidth: screenSize.width - 32),
                        // Showcase for the main statistics panel
                        child: Showcase(
                            key: two,
                            title: title_two,
                            description: description_two,
                            child: const MainPanel()),
                      ),
                      // Constrains the size of the info text on smaller screens
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 150, maxWidth: screenSize.width - 32),
                        // Showcase for the user information area
                        child: Showcase(
                          key: three,
                          title: title_three,
                          description: description_three,
                          child: InfoText(),
                        ),
                      ),
                      // Constrains the size of the navigation menu on smaller screens
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: screenSize.height * 0.5,
                            maxWidth: screenSize.width - 32),
                        // Showcase for the main navigation menu
                        child: Showcase(
                            key: four,
                            title: title_four,
                            description: description_four,
                            child: NavigationMenu(
                              // Navigate to the selected route using go_router
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
