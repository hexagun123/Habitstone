// theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

final themeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.light);

final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  return AppTheme.getTheme(themeMode);
});

// Add this function to get the next theme
AppThemeMode getNextTheme(AppThemeMode current) {
  final themes = AppThemeMode.values;
  final nextIndex = (themes.indexOf(current) + 1) % themes.length;
  return themes[nextIndex];
}

// Add this function to get the icon for a theme mode
IconData getThemeIcon(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return Icons.light_mode;
    case AppThemeMode.dark:
      return Icons.dark_mode;
    case AppThemeMode.sciFi:
      return Icons.rocket_launch;
    case AppThemeMode.soloLeveling:
      return Icons.auto_awesome;
  }
}
