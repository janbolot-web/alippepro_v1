import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFA5156D);
  static const Color darkPurple = Color(0xFF3D3656);
  static const Color lightPurple = Color(0xFF6A5B7B);
  static const Color background = Colors.white;
  static const Color inputBorder = Color(0xFFA5156D);
  static const Color buttonGradientStart = Color(0xFFA5156D);
  static const Color buttonGradientEnd = Color(0xFF603B85);
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkPurple,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.darkPurple, 
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.darkPurple,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkPurple,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightPurple,
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
    ),
  );
}