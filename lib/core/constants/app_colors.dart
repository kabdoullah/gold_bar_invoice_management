import 'package:flutter/material.dart';

/// Color palette faithful to the original desktop software (dark theme).
abstract final class AppColors {
  static const Color backgroundPrimary = Color(0xFF1A1A2E);
  static const Color backgroundTable = Color(0xFF16213E);
  static const Color tableHeader = Color(0xFF0F3460);

  /// Carat values are always displayed in this red, in UI and PDF alike.
  static const Color accentCarat = Color(0xFFE94560);

  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color tableBorder = Color(0xFF2D3561);

  static const Color syncSuccess = Color(0xFF4CAF50);
  static const Color syncWarning = Color(0xFFFFC107);
  static const Color syncError = Color(0xFFE94560);

  static const Color draftWarning = Color(0xFFFF9800);
}
