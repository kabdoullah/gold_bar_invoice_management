import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../sync/viewmodels/sync_viewmodel.dart';

/// Always-visible AppBar indicator of the cloud sync state.
/// Tapping it retries when the state is error or pending.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SyncViewModel>();

    final (color, label, icon) = switch (vm.status) {
      SyncStatus.synced => (
          AppColors.syncSuccess,
          'Synchronisé',
          Icons.cloud_done,
        ),
      SyncStatus.pending => (
          AppColors.syncWarning,
          '${vm.pendingCount} en attente',
          Icons.cloud_upload,
        ),
      SyncStatus.syncing => (
          AppColors.textPrimary,
          'Synchronisation…',
          null,
        ),
      SyncStatus.error => (
          AppColors.syncError,
          'Erreur sync',
          Icons.cloud_off,
        ),
    };

    return InkWell(
      onTap: vm.status == SyncStatus.error || vm.status == SyncStatus.pending
          ? vm.retry
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 14, color: color)
            else
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
