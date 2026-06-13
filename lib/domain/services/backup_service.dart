import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/prefs_keys.dart';
import '../../data/remote/google_drive/google_drive_service.dart';
import '../../data/services/export_service.dart';

/// Orchestrates export → upload → timestamp persistence.
///
/// Two paths:
/// - [performBackup] — manual, called by BackupViewModel; exposes an
///   optional [onExported] hook so the VM can update progress state
///   between the export and upload steps.
/// - [autoBackupIfConnected] — silent fire-and-forget, called after
///   saveAndPrint() and at app startup; swallows all errors.
class BackupService {
  BackupService(this._exportService, this._driveService);

  final ExportService      _exportService;
  final GoogleDriveService _driveService;

  /// Exports all saved invoices to JSON, uploads to Drive, and persists
  /// the success timestamp.
  ///
  /// [onExported] is called after the local JSON file is written and before
  /// the upload starts — lets the caller show intermediate progress.
  Future<void> performBackup({VoidCallback? onExported}) async {
    final file = await _exportService.exportToJson();
    onExported?.call();
    await _driveService.uploadBackup(file);
    await _persistSuccess();
  }

  /// Reads the last successful backup timestamp from SharedPreferences.
  /// Returns null if no backup has ever been performed.
  Future<DateTime?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final str   = prefs.getString(PrefsKeys.lastBackupAt);
    return str != null ? DateTime.parse(str) : null;
  }

  /// Fire-and-forget silent auto-backup. Never await from the caller.
  /// Skips if offline or Drive not already authorized (no dialogs in bg).
  Future<void> autoBackupIfConnected() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.every((r) => r == ConnectivityResult.none)) return;

      final authorized = await _driveService.isAuthorizedSilently();
      if (!authorized) return;

      await performBackup();
    } catch (_) {
      // Silent — failure surfaces as BackupReminderBanner after 3 days.
    }
  }

  Future<void> _persistSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PrefsKeys.lastBackupAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}
