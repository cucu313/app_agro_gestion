import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Define el ThemeData claro y oscuro de la app.
/// Estilo inspirado en apps profesionales de Apple: bordes redondeados,
/// tipografía limpia, superficies suaves y sombras discretas.
class AppTheme {
  AppTheme._();

  static const double radius = 16;

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.offWhite,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryGreen,
        secondary: AppColors.earthBrown,
        surface: AppColors.white,
        error: AppColors.danger,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.grayDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      textTheme: _textTheme(base.textTheme, AppColors.grayDark),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grayLight.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.grayLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryGreenLight,
        secondary: AppColors.earthLight,
        surface: AppColors.darkSurface,
        error: AppColors.danger,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.offWhite,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      textTheme: _textTheme(base.textTheme, AppColors.offWhite),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreenLight,
          foregroundColor: AppColors.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkSurfaceAlt,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color color) {
    return base.copyWith(
      headlineLarge: base.headlineLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: color),
      headlineMedium: base.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w700, color: color),
      titleLarge: base.titleLarge
          ?.copyWith(fontWeight: FontWeight.w600, color: color),
      titleMedium: base.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: color),
      bodyLarge: base.bodyLarge?.copyWith(color: color),
      bodyMedium: base.bodyMedium?.copyWith(color: color),
    );
  }
}
