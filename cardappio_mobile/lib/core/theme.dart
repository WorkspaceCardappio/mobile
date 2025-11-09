import 'package:flutter/material.dart';

class _AppColors {

  static const Color primary = Color(0xFFD94D27);

  static const Color darkSlate = Color(0xFF1F1F29);

  static const Color offWhite = Color(0xFFF5F4F7);

  static const Color secondaryText = Color(0xFF4C4C59);

  static const Color onDark = Color(0xFFFFFFFF);

}

final ThemeData appTheme = ThemeData(

  useMaterial3: true,
  scaffoldBackgroundColor: _AppColors.offWhite,

  colorScheme: ColorScheme.fromSeed(

    seedColor: _AppColors.primary,
    brightness: Brightness.light,

    primary: _AppColors.primary,
    onPrimary: _AppColors.onDark,

    surface: _AppColors.offWhite,
    background: _AppColors.offWhite,

    onSurface: _AppColors.darkSlate,
    onBackground: _AppColors.darkSlate

  ),

  appBarTheme: const AppBarTheme(

    backgroundColor: _AppColors.darkSlate,
    foregroundColor: _AppColors.onDark,
    elevation: 0,
    scrolledUnderElevation: 4.0,

    titleTextStyle: TextStyle(

      color: _AppColors.onDark,
      fontWeight: FontWeight.w600,
      fontSize: 20,

    ),

  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(

      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: _AppColors.darkSlate

    ),

    headlineMedium: TextStyle(

      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: _AppColors.darkSlate

    ),

    bodyMedium: TextStyle(
      fontSize: 16,
      color: _AppColors.secondaryText

    ),
  ),


  elevatedButtonTheme: ElevatedButtonThemeData(

    style: ElevatedButton.styleFrom(

      backgroundColor: _AppColors.primary,
      foregroundColor: _AppColors.onDark,
      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(8.0),

      ),

      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      elevation: 2.0,

    ),

  ),


  cardTheme: CardThemeData(

    color: _AppColors.offWhite,
    elevation: 1.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),

  ),

);