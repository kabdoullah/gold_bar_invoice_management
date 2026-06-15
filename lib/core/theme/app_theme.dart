import 'package:flutter/material.dart';

/// Provides Flutter [ThemeData] for both light and dark modes.
///
/// Raw `Color(0xFF...)` values live here and in `app_colors.dart` only.
/// Widgets read semantic colors via `AppColors.of(context)`.
abstract final class AppTheme {
  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF185FA5),
      secondary: Color(0xFFE94560),
      surface: Color(0xFF16213E),
      error: Color(0xFFE94560),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F3460),
      foregroundColor: Color(0xFFEEEEEE),
      elevation: 0,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF16213E),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(Color(0xFF0F3460)),
      dataRowColor: WidgetStatePropertyAll(Color(0xFF16213E)),
      dividerThickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F3460),
      labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2D3561), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2D3561), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE94560),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF2D3561),
        disabledForegroundColor: const Color(0xFF9E9E9E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE94560),
      foregroundColor: Color(0xFFEEEEEE),
    ),
    dividerColor: const Color(0xFF2D3561),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFEEEEEE)),
      bodyMedium: TextStyle(color: Color(0xFFEEEEEE)),
      labelMedium: TextStyle(color: Color(0xFF9E9E9E)),
    ),
  );

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F0),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF185FA5),
      secondary: Color(0xFFC0152A),
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFC0152A),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF185FA5),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFFFFFFF),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(Color(0xFFE6F1FB)),
      dataRowColor: WidgetStatePropertyAll(Color(0xFFFFFFFF)),
      dividerThickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F4FF),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD0D8E8), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD0D8E8), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC0152A),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFD0D8E8),
        disabledForegroundColor: const Color(0xFF6B7280),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFC0152A),
      foregroundColor: Color(0xFFFFFFFF),
    ),
    dividerColor: const Color(0xFFD0D8E8),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1A2E)),
      bodyMedium: TextStyle(color: Color(0xFF1A1A2E)),
      labelMedium: TextStyle(color: Color(0xFF6B7280)),
    ),
  );
}
