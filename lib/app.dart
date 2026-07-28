import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/state/settings_controller.dart';
import 'package:tidy/ui/shell/app_shell.dart';

class TidyApp extends ConsumerWidget {
  const TidyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return AnimatedTheme(
      data: settings.themeMode == ThemeMode.dark
          ? AppTheme.dark()
          : settings.themeMode == ThemeMode.light
              ? AppTheme.light()
              : (MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? AppTheme.dark()
                  : AppTheme.light()),
      duration: AppDurations.theme,
      child: MaterialApp(
        title: 'Tidy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode,
        home: const AppShell(),
      ),
    );
  }
}
