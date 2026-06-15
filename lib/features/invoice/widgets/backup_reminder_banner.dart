import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Amber banner shown when the last backup is > 3 days ago or never done.
/// Tapping "Sauvegarder →" triggers [onBackupNow] which the parent screen
/// wires to `/backup` navigation + refreshBackupStatus() on return.
class BackupReminderBanner extends StatelessWidget {
  const BackupReminderBanner({
    super.key,
    required this.message,
    required this.onBackupNow,
  });

  final String       message;
  final VoidCallback onBackupNow;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ColoredBox(
      color: colors.warning.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.backup_outlined,
              color: colors.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.warning,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: onBackupNow,
              style: TextButton.styleFrom(
                foregroundColor: colors.warning,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Sauvegarder →'),
            ),
          ],
        ),
      ),
    );
  }
}
