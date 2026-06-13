import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/remote/google_drive/google_drive_service.dart';
import '../viewmodels/backup_view_model.dart';

/// Backup & Restore screen — manual Drive backup and restore from a
/// previously uploaded backup file.
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarde & Restauration')),
      body: const _BackupBody(),
    );
  }
}

class _BackupBody extends StatefulWidget {
  const _BackupBody();

  @override
  State<_BackupBody> createState() => _BackupBodyState();
}

class _BackupBodyState extends State<_BackupBody> {
  DriveBackupFile? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackupViewModel>().loadAvailableBackups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BackupViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackupCard(vm: vm),
          const SizedBox(height: 16),
          _RestoreCard(
            vm: vm,
            selected: _selected,
            onSelect: (f) => setState(() => _selected = f),
          ),
          const SizedBox(height: 16),
          _WarningNote(),
        ],
      ),
    );
  }
}

// ─── Backup card ────────────────────────────────────────────────────────────

class _BackupCard extends StatelessWidget {
  const _BackupCard({required this.vm});
  final BackupViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundTable,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload_outlined,
                    color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Sauvegarde Google Drive',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Dernière sauvegarde : ${vm.lastBackupLabel ?? '…'}',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            if (vm.status == BackupStatus.error &&
                vm.errorMessage != null) ...[
              _ErrorBanner(message: vm.errorMessage!, onRetry: vm.backupNow),
              const SizedBox(height: 12),
            ],
            if (vm.status == BackupStatus.success) ...[
              const _SuccessBanner(label: 'Sauvegarde réussie'),
              const SizedBox(height: 12),
            ],
            _BackupButton(vm: vm),
          ],
        ),
      ),
    );
  }
}

class _BackupButton extends StatelessWidget {
  const _BackupButton({required this.vm});
  final BackupViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isBackingUp = vm.status == BackupStatus.exporting ||
        vm.status == BackupStatus.uploading;

    String label;
    if (vm.status == BackupStatus.exporting) {
      label = 'Export des données…';
    } else if (vm.status == BackupStatus.uploading) {
      label = 'Envoi vers Drive…';
    } else {
      label = 'Sauvegarder maintenant';
    }

    return ElevatedButton.icon(
      icon: isBackingUp
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.backup),
      label: Text(label),
      onPressed: vm.isWorking ? null : vm.backupNow,
    );
  }
}

// ─── Restore card ────────────────────────────────────────────────────────────

class _RestoreCard extends StatelessWidget {
  const _RestoreCard({
    required this.vm,
    required this.selected,
    required this.onSelect,
  });

  final BackupViewModel    vm;
  final DriveBackupFile?   selected;
  final ValueChanged<DriveBackupFile?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundTable,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.restore, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Restaurer depuis Drive',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textMuted),
                  tooltip: 'Actualiser',
                  onPressed: vm.isWorking ? null : vm.loadAvailableBackups,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vm.availableBackups.isEmpty)
              const Text(
                'Aucune sauvegarde disponible sur Drive.',
                style: TextStyle(color: AppColors.textMuted),
              )
            else
              RadioGroup<DriveBackupFile>(
                groupValue: selected,
                onChanged: (f) { if (!vm.isWorking) onSelect(f); },
                child: Column(
                  children: vm.availableBackups.map(
                    (f) => RadioListTile<DriveBackupFile>(
                      value: f,
                      title: Text(
                        f.fileName,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13),
                      ),
                      subtitle: Text(
                        _formatDate(f.createdAt),
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      activeColor: AppColors.accentCarat,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ).toList(),
                ),
              ),
            const SizedBox(height: 12),
            if (vm.status == BackupStatus.error &&
                vm.errorMessage != null) ...[
              _ErrorBanner(
                message: vm.errorMessage!,
                onRetry: selected != null
                    ? () => vm.restoreFromDrive(selected!)
                    : null,
              ),
              const SizedBox(height: 12),
            ],
            if (vm.status == BackupStatus.success) ...[
              const _SuccessBanner(label: 'Restauration réussie'),
              const SizedBox(height: 12),
            ],
            _RestoreButton(vm: vm, selected: selected),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2,'0')}/'
        '${l.month.toString().padLeft(2,'0')}/'
        '${l.year} '
        '${l.hour.toString().padLeft(2,'0')}:'
        '${l.minute.toString().padLeft(2,'0')}';
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.vm, required this.selected});
  final BackupViewModel  vm;
  final DriveBackupFile? selected;

  @override
  Widget build(BuildContext context) {
    final isRestoring = vm.status == BackupStatus.downloading ||
        vm.status == BackupStatus.importing;

    String label;
    if (vm.status == BackupStatus.downloading) {
      label = 'Téléchargement…';
    } else if (vm.status == BackupStatus.importing) {
      label = 'Import des données…';
    } else {
      label = 'Restaurer la sauvegarde sélectionnée';
    }

    return ElevatedButton.icon(
      icon: isRestoring
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.restore),
      label: Text(label),
      onPressed: (selected != null && !vm.isWorking)
          ? () => _confirmRestore(context)
          : null,
    );
  }

  Future<void> _confirmRestore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurer la sauvegarde ?'),
        content: const Text(
          'Toutes les factures enregistrées seront remplacées par '
          'celles de la sauvegarde.\n\n'
          'Les brouillons ne sont pas affectés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.syncError),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await vm.restoreFromDrive(selected!);
    }
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onRetry});
  final String    message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.syncError.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.syncError.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.syncError, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.syncError, fontSize: 12)),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Réessayer',
                  style: TextStyle(color: AppColors.syncError)),
            ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.syncSuccess.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: AppColors.syncSuccess.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.syncSuccess, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: AppColors.syncSuccess)),
        ],
      ),
    );
  }
}

class _WarningNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(Icons.warning_amber_rounded,
            color: AppColors.draftWarning, size: 16),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'La restauration remplace toutes les factures enregistrées. '
            'Les brouillons ne sont pas affectés.',
            style:
                TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
