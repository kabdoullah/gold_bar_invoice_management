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
    return ColoredBox(
      color: AppColors.draftWarning.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.backup_outlined,
              color: AppColors.draftWarning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.draftWarning,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: onBackupNow,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.draftWarning,
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
