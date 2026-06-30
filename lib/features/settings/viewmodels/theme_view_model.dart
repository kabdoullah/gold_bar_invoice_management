import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/prefs_keys.dart';

/// Manages the app theme mode (light / dark / system).
/// Persists the user's choice in SharedPreferences under [PrefsKeys.themeMode].
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _disposed = false; // Track lifecycle for safe notify across async gaps

  ThemeMode get themeMode => _themeMode;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return; // Never notify after dispose
    notifyListeners();
  }

  /// Call once at app startup. Loads the persisted choice.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = _decode(prefs.getString(PrefsKeys.themeMode));
    if (loaded == _themeMode) return; // Skip redundant rebuild (system→system)
    _themeMode = loaded;
    _safeNotify();
  }

  /// Sets an explicit mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    await _persist();
    _safeNotify();
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
