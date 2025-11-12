import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: 'Poppins',
    );

    return base.copyWith(
      cardColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.headingDark,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: AppColors.white,
      ),
    );
  }

  static ThemeData dark() {
    const scaffold = AppColors.darkScaffold;
    const elevated = AppColors.darkElevated;
    const card = AppColors.darkCard;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: card,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Poppins',
    );

    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    );

    return base.copyWith(
      textTheme: textTheme,
      cardColor: card,
      dividerColor: AppColors.darkStroke,
      colorScheme: base.colorScheme.copyWith(
        surface: card,
        surfaceContainerHighest: elevated,
        onSurface: AppColors.darkTextPrimary,
        primary: AppColors.primary,
        secondary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: card,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.darkTextPrimary
                : AppColors.darkTextPrimary.withValues(alpha: 0.6),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.darkTextPrimary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
