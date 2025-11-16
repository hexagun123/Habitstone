/// This file defines the theme management system for the application using Riverpod.
/// It includes providers for the current theme mode, a notifier to change the theme,
/// and utility functions to cycle through themes and get corresponding icons.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../provider/setting.dart';

/// Provides the `ThemeNotifier` to the widget tree.
/// This allows the UI to interact with the theme state, such as changing the
/// current theme mode.
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  // The notifier is initialized with a reference to the settings notifier to persist changes.
  return ThemeNotifier(ref.read(settingsProvider.notifier));
});

/// A `StateNotifier` that manages the application's active theme mode.
/// It synchronizes the theme state with the persistent settings.
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final SettingsNotifier _settingsNotifier;

  /// Initializes the theme state from the user's saved settings.
  ThemeNotifier(this._settingsNotifier)
      : super(_settingsNotifier.state.themeMode);

  /// Sets the application's theme mode and persists the change.
  /// It only updates the state if the new mode is different from the current one.
  Future<void> setTheme(AppThemeMode mode) async {
    if (state != mode) {
      state = mode; // Update the in-memory state.
      await _settingsNotifier.updateThemeMode(mode); // Persist the change.
    }
  }
}

/// Provides the actual `ThemeData` object based on the current `AppThemeMode`.
/// Widgets, particularly `MaterialApp`, will watch this provider to rebuild
/// with the correct theme when the mode changes.
final currentThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeProvider); // Listen to the current theme mode.
  return AppTheme.getTheme(mode); // Return the corresponding ThemeData.
});

/// Returns the next theme in the sequence of available `AppThemeMode` values.
/// This is useful for implementing a button that cycles through themes.
AppThemeMode getNextTheme(AppThemeMode current) {
  final themes = AppThemeMode.values; // Get all available theme modes.
  // Calculate the index of the next theme, wrapping around to the start.
  final nextIndex = (themes.indexOf(current) + 1) % themes.length;
  return themes[nextIndex];
}

/// Returns an appropriate icon for a given `AppThemeMode`.
/// This can be used in the UI to visually represent each theme option.
IconData getThemeIcon(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return Icons.sunny; // Icon for the light theme.
    case AppThemeMode.sciFiBlue:
      return Icons.rocket_launch; // Icon for the sci-fi theme.
    case AppThemeMode.warmOrange:
      return Icons.grass; // Icon for the warm theme.
    case AppThemeMode.modernGrey:
      return Icons.circle_outlined; // Icon for the modern grey theme.
  }
}
