import 'package:flutter/material.dart';

// Colors from requirements
const Color kBrownColor = Color(0xFF8B4513);
const Color kGreenColor = Color(0xFF228B22);
const Color kGoldColor = Color(0xFFFFD700);

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: kBrownColor,
        secondary: kGreenColor,
        tertiary: kGoldColor,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBrownColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrownColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: kGoldColor,
        secondary: kGreenColor,
        tertiary: kBrownColor,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Color(0xFF1E1E1E),
      ),
    );
  }
}
