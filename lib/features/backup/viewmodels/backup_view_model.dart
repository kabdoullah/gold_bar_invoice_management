import 'package:flutter/foundation.dart';

import '../../../data/remote/google_drive/google_drive_service.dart';
import '../../../domain/services/backup_service.dart';
import '../../../data/services/import_service.dart';

enum BackupStatus { idle, exporting, uploading, downloading, importing, success, error }

/// State for BackupScreen: manual backup, backup listing, and restore.
class BackupViewModel extends ChangeNotifier {
  BackupViewModel({
    required this._backupService,
    required this._importService,
    required this._driveService,
  });

  final BackupService      _backupService;
  final ImportService      _importService;
  final GoogleDriveService _driveService;

  BackupStatus          _status           = BackupStatus.idle;
  List<DriveBackupFile> _availableBackups = const [];
  String?               _lastBackupLabel;
  String?               _errorMessage;

  BackupStatus          get status           => _status;
  List<DriveBackupFile> get availableBackups => _availableBackups;
  String?               get lastBackupLabel  => _lastBackupLabel;
  String?               get errorMessage     => _errorMessage;

  bool get isWorking =>
      _status == BackupStatus.exporting  ||
      _status == BackupStatus.uploading  ||
      _status == BackupStatus.downloading ||
      _status == BackupStatus.importing;

  /// Call once after construction (done by di.dart via `..init()`).
  Future<void> init() async {
    final date = await _backupService.getLastBackupDate();
    _lastBackupLabel = date != null ? _formatDate(date) : 'Jamais';
    notifyListeners();
  }

  /// Manual backup triggered from BackupScreen.
  Future<void> backupNow() async {
    _errorMessage = null;
    _status       = BackupStatus.exporting;
    notifyListeners();
    try {
      await _backupService.performBackup(
        onExported: () {
          _status = BackupStatus.uploading;
          notifyListeners();
        },
      );
      _lastBackupLabel = _formatDate(DateTime.now());
      _status          = BackupStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = BackupStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Loads available backups from Drive into [availableBackups].
  Future<void> loadAvailableBackups() async {
    _errorMessage = null;
    try {
      _availableBackups = await _driveService.listBackups();
    } catch (e) {
      _errorMessage     = e.toString();
      _availableBackups = const [];
    }
    notifyListeners();
  }

  /// Downloads [backup] from Drive and imports it into the local DB.
  Future<void> restoreFromDrive(DriveBackupFile backup) async {
    _errorMessage = null;
    _status       = BackupStatus.downloading;
    notifyListeners();
    try {
      final file = await _driveService.downloadBackup(backup.driveFileId);
      _status    = BackupStatus.importing;
      notifyListeners();
      await _importService.importFromJson(file);
      _status = BackupStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = BackupStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Resets a terminal state (success / error) back to idle.
  void reset() {
    _status       = BackupStatus.idle;
    _errorMessage = null;
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
