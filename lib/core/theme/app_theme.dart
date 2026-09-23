import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF00A8D8);
  static const darkText = Color(0xFF171717);
  static const background = Color(0xFFFFFFFF);
  static const card = Color(0xFFF8F8F8);
  static const softBlue = Color(0xFFEAF8FC);
  static const brandMedi = Color(0xFF0172A7);
  static const brandPedia = Color(0xFF001152);
  static const detailFavorite = Color(0xFFECECEC);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          AppColors.background,
      fontFamily: 'Montserrat',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
