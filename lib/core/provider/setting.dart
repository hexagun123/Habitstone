// lib/core/provider/settings.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/settings.dart';
import '../data/hive.dart';
import 'hive.dart'; 
import '../theme/app_theme.dart';

// 3. This is the only part that changes
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  // Instead of using the global 'repository'...
  // ...we now watch the provider to get the HiveRepository instance.
  final hiveRepository = ref.watch(hiveRepositoryProvider);
  
  // Then, we pass that instance to our notifier.
  return SettingsNotifier(hiveRepository);
});

// The SettingsNotifier class is already correct and needs NO changes.
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