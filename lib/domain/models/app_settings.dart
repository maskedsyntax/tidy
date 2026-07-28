import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.listsPaneOpen = true,
    this.chatPaneOpen = false,
  });

  final ThemeMode themeMode;

  /// Left lists sidebar visible.
  final bool listsPaneOpen;

  /// Right AI assistant pane visible.
  final bool chatPaneOpen;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? listsPaneOpen,
    bool? chatPaneOpen,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      listsPaneOpen: listsPaneOpen ?? this.listsPaneOpen,
      chatPaneOpen: chatPaneOpen ?? this.chatPaneOpen,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'listsPaneOpen': listsPaneOpen,
        'chatPaneOpen': chatPaneOpen,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final name = json['themeMode'] as String? ?? 'system';
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.system,
    );
    return AppSettings(
      themeMode: mode,
      listsPaneOpen: json['listsPaneOpen'] as bool? ?? true,
      // Default closed for a calmer first surface; enthusiasts open it once.
      chatPaneOpen: json['chatPaneOpen'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [themeMode, listsPaneOpen, chatPaneOpen];
}
