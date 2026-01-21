// This file defines the theme management system for the application using Riverpod.
// which will be used in the settings provider and some of the UI

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'settings.dart';

/// provides the current theme mode stored in settings
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier(ref.read(settingsProvider.notifier));
});

/// Manages the application's theme state.
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final SettingsNotifier _settingsNotifier;

  /// Initializes the theme state from the user's saved settings in hive
  ThemeNotifier(this._settingsNotifier)
      : super(_settingsNotifier.state.themeMode);

  /// Sets the application's theme mode and persists the change.
  /// It only updates the state if the new mode is different from the current one.
  Future<void> setTheme(AppThemeMode mode) async {
    if (state != mode) {
      state = mode; // Update the in-memory state.
      await _settingsNotifier.updateThemeMode(mode);
    }
  }
}

/// gets the current theme for the UI for the settings
/// used for switching themes and displaying the current theme
final currentThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeProvider); 
  return AppTheme.getTheme(mode); 
});

/// Returns the next theme in the sequence of available `AppThemeMode` values.
AppThemeMode getNextTheme(AppThemeMode current) {
  final themes = AppThemeMode.values; // Get all available theme modes.
  // Calculate the index of the next theme, wrapping around to the start.
  final nextIndex = (themes.indexOf(current) + 1) % themes.length;
  return themes[nextIndex];
}

/// Returns an appropriate icon for a given `AppThemeMode`.
/// used in the UI
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
