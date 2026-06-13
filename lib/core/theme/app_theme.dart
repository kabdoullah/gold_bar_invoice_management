import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Dark theme faithful to the original desktop software.
abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.tableHeader,
        secondary: AppColors.accentCarat,
        surface: AppColors.backgroundTable,
        error: AppColors.syncError,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.tableHeader,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.tableBorder,
      dataTableTheme: const DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(AppColors.tableHeader),
        dataRowColor: WidgetStatePropertyAll(AppColors.backgroundTable),
        dividerThickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tableHeader,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.backgroundTable,
          disabledForegroundColor: AppColors.textMuted,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentCarat,
        foregroundColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundTable,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.tableBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.tableBorder),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
