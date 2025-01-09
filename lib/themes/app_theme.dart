import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F5DC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
    );
  }
} 