// lib/core/provider/settings.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/settings.dart';
import '../data/hive.dart';
import 'app.dart';
import '../theme/app_theme.dart';

/// settings provider 
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final hiveRepository = ref.watch(hiveRepositoryProvider);
  return SettingsNotifier(hiveRepository);
});

/// Manages setting states
/// serves as a method holder for modification in the settings
class SettingsNotifier extends StateNotifier<Settings> {
  final HiveRepository _repository;

  /// getting the settings from the hive repository
  SettingsNotifier(this._repository) : super(_repository.getSettings());

  /// allows the update of the themeMode, which is a flutter variable for themes
  /// enum AppThemeMode helps with the process of switching to the correct theme
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _repository.updateThemeMode(themeMode);
  }

  /// allows the updating of weight if called by the main applciation
  Future<void> updateWeight(int weight) async {
    state = state.copyWith(weight: weight);
    await _repository.updateWeight(weight);
  }
}
