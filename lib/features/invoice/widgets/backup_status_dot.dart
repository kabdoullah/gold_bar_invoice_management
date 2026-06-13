import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../viewmodels/invoice_entry_viewmodel.dart';

/// Small colored dot in the AppBar reflecting backup freshness:
/// orange when a backup is due (never done or > 3 days), green otherwise.
/// Reads the global [InvoiceEntryViewModel] (same source as the banner).
class BackupStatusDot extends StatelessWidget {
  const BackupStatusDot({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceEntryViewModel>();
    final due = vm.shouldShowBackupReminder;
    final color = due ? AppColors.syncWarning : AppColors.syncSuccess;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Tooltip(
        message: vm.backupReminderMessage,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
