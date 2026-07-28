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

  Future<void> _save(AppSettings next) async {
    state = next;
    await _repo.save(state);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _save(state.copyWith(themeMode: mode));
  }

  Future<void> cycleTheme() async {
    final next = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  Future<void> setListsPaneOpen(bool open) async {
    await _save(state.copyWith(listsPaneOpen: open));
  }

  Future<void> setChatPaneOpen(bool open) async {
    await _save(state.copyWith(chatPaneOpen: open));
  }

  Future<void> toggleListsPane() async {
    await setListsPaneOpen(!state.listsPaneOpen);
  }

  Future<void> toggleChatPane() async {
    await setChatPaneOpen(!state.chatPaneOpen);
  }

  /// Hide both side panes — pure tasks ("pen and paper").
  Future<void> enterFocusMode() async {
    await _save(state.copyWith(listsPaneOpen: false, chatPaneOpen: false));
  }

  /// Show both side panes — full workspace.
  Future<void> enterFullMode() async {
    await _save(state.copyWith(listsPaneOpen: true, chatPaneOpen: true));
  }
}

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(settingsRepositoryProvider));
});
