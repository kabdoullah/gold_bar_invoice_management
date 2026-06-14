import 'package:flutter/foundation.dart';

import '../../../data/remote/google_drive/google_drive_service.dart';
import '../../../domain/services/backup_service.dart';
import '../../../data/services/import_service.dart';

/// Phases of a manual backup.
enum BackupPhase { idle, exporting, uploading, success, error }

/// Phases of a restore.
enum RestorePhase { idle, downloading, importing, success, error }

/// State for BackupScreen: manual backup, backup listing, and restore.
///
/// Backup and restore track their state independently so a success/error in
/// one operation never paints the other card's banner.
class BackupViewModel extends ChangeNotifier {
  BackupViewModel({
    required this._backupService,
    required this._importService,
    required this._driveService,
  });

  final BackupService      _backupService;
  final ImportService      _importService;
  final GoogleDriveService _driveService;

  BackupPhase           _backupPhase      = BackupPhase.idle;
  RestorePhase          _restorePhase     = RestorePhase.idle;
  List<DriveBackupFile> _availableBackups = const [];
  String?               _lastBackupLabel;
  String?               _backupError;
  String?               _restoreError;

  BackupPhase           get backupPhase      => _backupPhase;
  RestorePhase          get restorePhase     => _restorePhase;
  List<DriveBackupFile> get availableBackups => _availableBackups;
  String?               get lastBackupLabel  => _lastBackupLabel;
  String?               get backupError      => _backupError;
  String?               get restoreError     => _restoreError;

  bool get isBackingUp =>
      _backupPhase == BackupPhase.exporting ||
      _backupPhase == BackupPhase.uploading;

  bool get isRestoring =>
      _restorePhase == RestorePhase.downloading ||
      _restorePhase == RestorePhase.importing;

  bool get isWorking => isBackingUp || isRestoring;

  /// Call once after construction (done by di.dart via `..init()`).
  Future<void> init() async {
    final date = await _backupService.getLastBackupDate();
    _lastBackupLabel = date != null ? _formatDate(date) : 'Jamais';
    notifyListeners();
  }

  /// Manual backup triggered from BackupScreen.
  Future<void> backupNow() async {
    _backupError = null;
    _backupPhase = BackupPhase.exporting;
    notifyListeners();
    try {
      await _backupService.performBackup(
        onExported: () {
          _backupPhase = BackupPhase.uploading;
          notifyListeners();
        },
      );
      _lastBackupLabel = _formatDate(DateTime.now());
      _backupPhase     = BackupPhase.success;
    } catch (e) {
      _backupError = e.toString();
      _backupPhase = BackupPhase.error;
    } finally {
      notifyListeners();
    }
  }

  /// Loads available backups from Drive into [availableBackups].
  Future<void> loadAvailableBackups() async {
    _restoreError = null;
    try {
      _availableBackups = await _driveService.listBackups();
    } catch (e) {
      _restoreError     = e.toString();
      _restorePhase     = RestorePhase.error;
      _availableBackups = const [];
    }
    notifyListeners();
  }

  /// Downloads [backup] from Drive and imports it into the local DB.
  Future<void> restoreFromDrive(DriveBackupFile backup) async {
    _restoreError = null;
    _restorePhase = RestorePhase.downloading;
    notifyListeners();
    try {
      final file = await _driveService.downloadBackup(backup.driveFileId);
      _restorePhase = RestorePhase.importing;
      notifyListeners();
      await _importService.importFromJson(file);
      _restorePhase = RestorePhase.success;
    } catch (e) {
      _restoreError = e.toString();
      _restorePhase = RestorePhase.error;
    } finally {
      notifyListeners();
    }
  }

  /// Resets both terminal states (success / error) back to idle.
  void reset() {
    _backupPhase  = BackupPhase.idle;
    _restorePhase = RestorePhase.idle;
    _backupError  = null;
    _restoreError = null;
    notifyListeners();
  }

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2,'0')}/'
        '${l.month.toString().padLeft(2,'0')}/'
        '${l.year} à '
        '${l.hour.toString().padLeft(2,'0')}:'
        '${l.minute.toString().padLeft(2,'0')}';
  }
}
