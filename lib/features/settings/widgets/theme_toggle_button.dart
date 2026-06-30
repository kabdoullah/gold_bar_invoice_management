import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/theme_view_model.dart';

/// AppBar action that toggles light/dark. Shows a sun while dark is active
/// (tap → light) and a moon while light is active (tap → dark). Resolves
/// [ThemeMode.system] against the device brightness.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final isDark = themeVm.themeMode == ThemeMode.dark ||
        (themeVm.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      ),
      tooltip: isDark ? 'Mode clair' : 'Mode sombre',
      // Set the opposite of what's currently visible — works even from
      // ThemeMode.system (toggling the raw mode would waste the first tap).
      onPressed: () => themeVm.setThemeMode(
        isDark ? ThemeMode.light : ThemeMode.dark,
      ),
    );
  }
}
