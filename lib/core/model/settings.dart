// lib/core/model/settings.dart
import 'package:hive/hive.dart';
import '../theme/app_theme.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class Settings extends HiveObject {
  @HiveField(0)
  late int themeModeIndex;

  @HiveField(1)
  late int weight;

  Settings({
    required this.themeModeIndex,
    required this.weight,
  });

  // Getter to convert index to AppThemeMode
  AppThemeMode get themeMode {
    if (themeModeIndex >= 0 && themeModeIndex < AppThemeMode.values.length) {
      return AppThemeMode.values[themeModeIndex];
    }
    return AppThemeMode.light;
  }

  // Setter to convert AppThemeMode to index
  set themeMode(AppThemeMode mode) {
    themeModeIndex = mode.index;
  }

  // Default constructor
  Settings.create()
      : themeModeIndex = AppThemeMode.light.index,
        weight = 5;

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
