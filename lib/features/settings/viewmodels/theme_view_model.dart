import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/prefs_keys.dart';

/// Manages the app theme mode (light / dark / system).
/// Persists the user's choice in SharedPreferences under [PrefsKeys.themeMode].
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Call once at app startup. Loads the persisted choice.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _decode(prefs.getString(PrefsKeys.themeMode));
    notifyListeners();
  }

  /// Toggles between light and dark.
  /// If current mode is system, switches to dark first.
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _persist();
    notifyListeners();
  }

  /// Sets an explicit mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.themeMode, _encode(_themeMode));
  }

  static ThemeMode _decode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
