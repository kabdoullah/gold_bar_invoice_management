import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';

/// Prominent banner shown at the top of the invoice list when an
/// unfinished (draft) invoice exists.
class DraftBanner extends StatelessWidget {
  const DraftBanner({
    super.key,
    required this.draftDate,
    required this.onResume,
    required this.onDiscard,
  });

  final DateTime draftDate;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.draftWarning.withValues(alpha: 0.15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.draftWarning, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.draftWarning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Facture non terminée du '
                    '${NumberFormatter.date(draftDate)}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDiscard,
                  child: const Text(
                    'Abandonner',
                    style: TextStyle(color: AppColors.syncError),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onResume,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.draftWarning,
                  ),
                  child: const Text('Reprendre'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
