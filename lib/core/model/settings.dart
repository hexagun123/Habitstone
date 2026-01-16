// settings.dart
// just the model for the settings, used this because I planned that there will
// be more settings in the future

import 'package:hive/hive.dart';
import '../theme/app_theme.dart';

part 'settings.g.dart'; 

@HiveType(typeId: 3) 
class Settings {

  /// the index of the theme
  @HiveField(0) 
  int themeModeIndex;

  /// weight used in random generation of tasks
  @HiveField(1)
  int weight;

  Settings({
    required this.themeModeIndex,
    required this.weight,
  });

  /// function with some tweaks
  AppThemeMode get themeMode {
    if (themeModeIndex >= 0 && themeModeIndex < AppThemeMode.values.length) {
      return AppThemeMode.values[themeModeIndex];
    }
    return AppThemeMode.light; // Default to light theme
  }

  /// set theme with a mode
  set themeMode(AppThemeMode mode) {
    themeModeIndex = mode.index;
  }

  factory Settings.create() {
    return Settings(
      themeModeIndex: AppThemeMode.light.index, 
      weight: 5, // Default weight
    );
  }

  Settings copyWith({
    AppThemeMode? themeMode,
    int? weight,
  }) {
    return Settings(
      themeModeIndex: themeMode?.index ?? themeModeIndex,
      weight: weight ?? this.weight,
    );
  }
}
