import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/data/settings_repository.dart';
import 'package:tidy/domain/models/app_settings.dart';

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._repo) : super(const AppSettings()) {
    _init();
  }

  final SettingsRepository _repo;
  bool loaded = false;

  Future<void> _init() async {
    state = await _repo.load();
    loaded = true;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.save(state);
  }

  Future<void> cycleTheme() async {
    final next = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }
}

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(settingsRepositoryProvider));
});
