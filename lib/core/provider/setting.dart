// lib/core/provider/settings.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/settings.dart';
import '../data/hive.dart';
import '../../main.dart';
import '../theme/app_theme.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<Settings> {
  final HiveRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _repository.updateThemeMode(themeMode);
  }

  Future<void> updateWeight(int weight) async {
    state = state.copyWith(weight: weight);
    await _repository.updateWeight(weight);
  }
}