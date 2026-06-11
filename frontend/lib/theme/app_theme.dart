import 'package:flutter/material.dart';
import 'app_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.Background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.Accent,
        surface: AppColors.White,
        error: AppColors.Error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.Background,
        foregroundColor: AppColors.Primary,
        centerTitle: false,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.White,
        indicatorColor: AppColors.Secondary,
      ),

      cardTheme: CardThemeData(
        color: AppColors.White,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.White,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}