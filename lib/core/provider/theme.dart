// theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/hive.dart';
import '../data/hive.dart';
import '../theme/app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  final repository = ref.watch(hiveRepositoryProvider);
  return ThemeNotifier(repository);
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final HiveRepository _repository;

  ThemeNotifier(this._repository)
      : super(_repository.getThemeMode() ?? AppThemeMode.light);
  Future<void> setTheme(AppThemeMode mode) async {
    if (state != mode) {
      state = mode;
      await _repository.saveThemeMode(mode);
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
