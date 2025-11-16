// lib/core/provider/settings.dart
// This file sets up the state management for application-wide settings using Riverpod.
// It defines a notifier to handle settings changes and a provider to expose
// these settings to the rest of the application, ensuring that changes are
// persisted and the UI is updated accordingly.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/settings.dart';
import '../data/hive.dart';
import 'app.dart';
import '../theme/app_theme.dart';

/// Provides the [SettingsNotifier] to the widget tree.
///
/// This provider is responsible for creating the `SettingsNotifier` and supplying
/// it with its dependency, the `HiveRepository`. Widgets can watch this provider
/// to access the current `Settings` object or the `SettingsNotifier` instance
/// to trigger updates.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  // Watch the hiveRepositoryProvider to get the persistence layer instance.
  final hiveRepository = ref.watch(hiveRepositoryProvider);

  // Pass the repository instance to the notifier upon creation.
  return SettingsNotifier(hiveRepository);
});

/// Manages the application's `Settings` state.
///
/// This notifier handles the business logic for updating settings. It communicates
/// with the `HiveRepository` to persist any changes to local storage. The state
/// is immutable; each update creates a new `Settings` object.
class SettingsNotifier extends StateNotifier<Settings> {
  final HiveRepository _repository;

  /// Initializes the notifier by loading the settings from the repository.
  /// The initial state is set to the settings stored on the device.
  SettingsNotifier(this._repository) : super(_repository.getSettings());

  /// Updates the application's theme mode.
  ///
  /// It first updates the in-memory state, which notifies all listeners,
  /// and then asynchronously saves the new theme mode to the repository.
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _repository.updateThemeMode(themeMode);
  }

  /// Updates the weight value used in the task selection algorithm.
  ///
  /// Similar to updating the theme, this method updates the local state
  /// immediately and then persists the new weight value to storage.
  Future<void> updateWeight(int weight) async {
    state = state.copyWith(weight: weight);
    await _repository.updateWeight(weight);
  }
}
