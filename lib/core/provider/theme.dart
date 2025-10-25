// theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../provider/setting.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier(ref.read(settingsProvider.notifier));
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final SettingsNotifier _settingsNotifier;

  ThemeNotifier(this._settingsNotifier) : super(_settingsNotifier.state.themeMode);

  Future<void> setTheme(AppThemeMode mode) async {
    if (state != mode) {
      state = mode;
      await _settingsNotifier.updateThemeMode(mode);
    }
  }
}

final currentThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeProvider);
  return AppTheme.getTheme(mode);
});

AppThemeMode getNextTheme(AppThemeMode current) {
  final themes = AppThemeMode.values;
  final nextIndex = (themes.indexOf(current) + 1) % themes.length;
  return themes[nextIndex];
}

IconData getThemeIcon(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return Icons.sunny;
    case AppThemeMode.sciFiBlue:
      return Icons.rocket_launch;
    case AppThemeMode.warmOrange:
      return Icons.grass;
    case AppThemeMode.modernGrey:
      return Icons.circle_outlined;
  }
}
