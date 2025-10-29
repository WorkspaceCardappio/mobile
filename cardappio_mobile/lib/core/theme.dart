import 'package:flutter/material.dart';

class _AppColors {
  static const Color primaryText = Color(0xFF2C3E50);
  static const Color secondaryText = Color(0xFF495057);

  static const Color primaryBlack = Color(0xFF1E1E1E);
  static const Color primaryBlack87 = Color(0xDF1E1E1E);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color appBarBackground = Color(0xE52C3E50);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _AppColors.primaryBlack,
    primary: _AppColors.primaryBlack87,
    secondary: _AppColors.primaryText,
    surface: _AppColors.surface,
    background: _AppColors.background,
    onPrimary: _AppColors.onPrimary,
    onBackground: _AppColors.primaryText,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _AppColors.appBarBackground,
    foregroundColor: _AppColors.onPrimary,
    elevation: 4.0,
    scrolledUnderElevation: 4.0,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: _AppColors.primaryText,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: _AppColors.primaryText,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: _AppColors.secondaryText,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
);