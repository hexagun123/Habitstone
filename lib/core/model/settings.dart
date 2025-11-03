// core/model/settings.dart
import 'package:hive/hive.dart';
import '../theme/app_theme.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
// --- THE FIX: REMOVE "extends HiveObject" ---
class Settings { 
  @HiveField(0)
  int themeModeIndex; // Removed 'late'

  @HiveField(1)
  int weight; // Removed 'late'

  Settings({
    required this.themeModeIndex,
    required this.weight,
  });

  // This part is unchanged
  AppThemeMode get themeMode {
    if (themeModeIndex >= 0 && themeModeIndex < AppThemeMode.values.length) {
      return AppThemeMode.values[themeModeIndex];
    }
    return AppThemeMode.light;
  }

  set themeMode(AppThemeMode mode) {
    themeModeIndex = mode.index;
  }

  // Factory constructor for defaults
  factory Settings.create() {
    return Settings(
      themeModeIndex: AppThemeMode.light.index,
      weight: 5,
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