import 'package:flutter/material.dart';

/// Design tokens matching the reference mockup.
abstract final class AppColors {
  // Light
  static const lightAppBg = Color(0xFFF7F7F8);
  static const lightSidebar = Color(0xFFF0F0F2);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightHover = Color(0xFFEBEBED);
  static const lightSelected = Color(0xFFE4E4E7);
  static const lightTextPrimary = Color(0xFF1A1A1C);
  static const lightTextMuted = Color(0xFF8E8E93);
  static const lightBorder = Color(0xFFE5E5EA);
  static const lightInputBg = Color(0xFFF5F5F7);

  // Dark
  static const darkAppBg = Color(0xFF0F0F10);
  static const darkSidebar = Color(0xFF161618);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkHover = Color(0xFF2A2A2C);
  static const darkSelected = Color(0xFF2C2C2E);
  static const darkTextPrimary = Color(0xFFF5F5F7);
  static const darkTextMuted = Color(0xFF8E8E93);
  static const darkBorder = Color(0xFF2C2C2E);
  static const darkInputBg = Color(0xFF252528);

  static const checkbox = Color(0xFF0A84FF);
  static const work = Color(0xFF3B82F6);
  static const personal = Color(0xFF22C55E);
  static const learning = Color(0xFFA855F7);

  static const paletteScrim = Color(0x66000000);
}

abstract final class AppRadii {
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 180);
  static const theme = Duration(milliseconds: 200);
  static const palette = Duration(milliseconds: 160);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.checkbox,
        onPrimary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightAppBg,
      dividerColor: AppColors.lightBorder,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.lightHover.withValues(alpha: 0.6),
      textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextMuted),
      inputDecorationTheme: _inputDecoration(
        AppColors.lightInputBg,
        AppColors.lightBorder,
        AppColors.lightTextMuted,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        elevation: 8,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        elevation: 6,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.checkbox,
        onPrimary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkAppBg,
      dividerColor: AppColors.darkBorder,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.darkHover.withValues(alpha: 0.6),
      textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextMuted),
      inputDecorationTheme: _inputDecoration(
        AppColors.darkInputBg,
        AppColors.darkBorder,
        AppColors.darkTextMuted,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        elevation: 8,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        elevation: 6,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 12),
      ),
    );
  }

  static const String? _fontFamily = null; // system UI

  static TextTheme _textTheme(Color primary, Color muted) {
    return TextTheme(
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.35,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.6,
      ),
    );
  }

  static InputDecorationTheme _inputDecoration(
    Color fill,
    Color border,
    Color hint,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.checkbox, width: 1.5),
      ),
    );
  }
}

/// Extension for theme-aware surface colors used across the shell.
extension AppThemeX on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  Color get appBg =>
      isDark ? AppColors.darkAppBg : AppColors.lightAppBg;

  Color get sidebarBg =>
      isDark ? AppColors.darkSidebar : AppColors.lightSidebar;

  Color get surfaceBg =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;

  Color get hoverBg =>
      isDark ? AppColors.darkHover : AppColors.lightHover;

  Color get selectedBg =>
      isDark ? AppColors.darkSelected : AppColors.lightSelected;

  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get textMuted =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  Color get borderColor =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get inputBg =>
      isDark ? AppColors.darkInputBg : AppColors.lightInputBg;
}
