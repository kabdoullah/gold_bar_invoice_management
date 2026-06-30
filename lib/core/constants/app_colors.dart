import 'package:flutter/material.dart';

/// Centralized color system for both light and dark themes.
///
/// Use `AppColors.of(context)` to get the correct [AppColorScheme] for the
/// current theme brightness. Never use hardcoded `Color(0xFF...)` values
/// outside this file (and `app_theme.dart`).
abstract final class AppColors {
  /// Returns the [AppColorScheme] for the current theme brightness.
  /// Usage: `final colors = AppColors.of(context);`
  static AppColorScheme of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColorScheme.dark() : AppColorScheme.light();
  }
}

/// Holds all semantic color slots for one theme.
/// Access via [AppColors.of] — never instantiate directly.
class AppColorScheme {
  final Color background;
  final Color surface;
  final Color tableHeader;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDimmed;
  final Color accentCarat; // carat column — always prominent
  final Color accentAction; // "Ajouter barre" button
  final Color accentSave; // "Enregistrer & Imprimer" button
  final Color totalBackground;
  final Color totalText;
  final Color success;
  final Color warning;
  final Color error;
  final Color appBarBackground;
  final Color appBarForeground;
  final Color nombreBarresBg;
  final Color nombreBarresFg;

  const AppColorScheme._({
    required this.background,
    required this.surface,
    required this.tableHeader,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDimmed,
    required this.accentCarat,
    required this.accentAction,
    required this.accentSave,
    required this.totalBackground,
    required this.totalText,
    required this.success,
    required this.warning,
    required this.error,
    required this.appBarBackground,
    required this.appBarForeground,
    required this.nombreBarresBg,
    required this.nombreBarresFg,
  });

  factory AppColorScheme.dark() => const AppColorScheme._(
    background: Color(0xFF1A1A2E),
    surface: Color(0xFF16213E),
    tableHeader: Color(0xFF0F3460),
    border: Color(0xFF2D3561),
    textPrimary: Color(0xFFEEEEEE),
    textSecondary: Color(0xFFC5C8D6),
    textDimmed: Color(0xFF7A8199),
    accentCarat: Color(0xFFFF5C72),
    accentAction: Color(0xFF185FA5),
    accentSave: Color(0xFFE94560),
    totalBackground: Color(0xFF0F3460),
    totalText: Color(0xFFEEEEEE),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFE94560),
    appBarBackground: Color(0xFF0F3460),
    appBarForeground: Color(0xFFEEEEEE),
    nombreBarresBg: Color(0xFF0F3460),
    nombreBarresFg: Color(0xFFEEEEEE),
  );

  factory AppColorScheme.light() => const AppColorScheme._(
    background: Color(0xFFF5F5F0),
    surface: Color(0xFFFFFFFF),
    tableHeader: Color(0xFFE6F1FB),
    border: Color(0xFFD0D8E8),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    textDimmed: Color(0xFFB0B8C8),
    accentCarat: Color(0xFFC0152A),
    accentAction: Color(0xFF185FA5),
    accentSave: Color(0xFFC0152A),
    totalBackground: Color(0xFFE6F1FB),
    totalText: Color(0xFF0C447C),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFE65100),
    error: Color(0xFFC0152A),
    appBarBackground: Color(0xFF185FA5),
    appBarForeground: Color(0xFFFFFFFF),
    nombreBarresBg: Color(0xFFE6F1FB),
    nombreBarresFg: Color(0xFF0C447C),
  );
}
