import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E1E1E), // Preto
    primary: const Color(0xDF1E1E1E),
    secondary: const Color(0xEA2C3E50), // Cor secundária para textos/detalhes
    surface: const Color(0xFFFFFFFF), // Fundo de Cards
    background: const Color(0xFFF8F9FA), // Fundo da tela
    onPrimary: Colors.white,
    onBackground: const Color(0xED2C3E50),
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xE52C3E50),
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF2C3E50)),
    headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: Color(0xFF2C3E50)),
    bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF495057)),
  ),
  // CORREÇÃO: Usar CardThemeData em vez de CardTheme
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
  ),
);