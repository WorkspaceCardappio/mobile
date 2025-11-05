import 'package:flutter/material.dart';

// The new, refined color palette based on user input (d94d27, 1f1f29, f5f4f7)
class _AppColors {
  // Main Accent: Muted Terracotta/Reddish Orange (d94d27)
  static const Color primary = Color(0xFFD94D27);

  // Darkest Color: Deep Slate/Indigo (1f1f29) - Used for Text and AppBar
  static const Color darkSlate = Color(0xFF1F1F29);

  // Lightest Color: Soft Off-White/Lavender (f5f4f7) - Used for Background and Surface
  static const Color offWhite = Color(0xFFF5F4F7);

  // Secondary Text Color: A slightly lighter, less intense slate for supporting text
  static const Color secondaryText = Color(0xFF4C4C59);

  // Text/Icons on dark surfaces
  static const Color onDark = Color(0xFFFFFFFF);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  // Use the off-white as the main canvas background for a clean, sober look
  scaffoldBackgroundColor: _AppColors.offWhite,

  colorScheme: ColorScheme.fromSeed(
    seedColor: _AppColors.primary, // Muted orange drives the scheme's feel
    brightness: Brightness.light,

    // Primary: The terracotta accent
    primary: _AppColors.primary,
    onPrimary: _AppColors.onDark,

    // Surface/Background: The soft off-white
    surface: _AppColors.offWhite,
    background: _AppColors.offWhite,

    // On-Surface/On-Background: The deep slate for primary contrast text/icons
    onSurface: _AppColors.darkSlate,
    onBackground: _AppColors.darkSlate,
  ),

  // AppBar uses the dark slate for strong, modern contrast
  appBarTheme: const AppBarTheme(
    backgroundColor: _AppColors.darkSlate,
    foregroundColor: _AppColors.onDark, // White text on dark slate
    elevation: 0, // Modern apps often use no elevation on the AppBar
    scrolledUnderElevation: 4.0,
    titleTextStyle: TextStyle(
      color: _AppColors.onDark,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
  ),

  // Text Styling: Using the deep slate color
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: _AppColors.darkSlate,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: _AppColors.darkSlate,
    ),
    // Body text uses a slightly less aggressive contrast (secondaryText)
    bodyMedium: TextStyle(
      fontSize: 16,
      color: _AppColors.secondaryText,
    ),
  ),

  // Buttons use the primary color and have a clean, modern shape
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

  // Card Styling: Subtle elevation and rounded corners for a gentle lift
  // FIX: Changed 'CardTheme' to 'CardThemeData'
  cardTheme: CardThemeData(
    color: _AppColors.offWhite,
    elevation: 1.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
);