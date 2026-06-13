import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/business_exceptions.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/services/backup_service.dart';

/// State for InvoiceListScreen: saved invoices, draft banner, backup reminder.
class InvoiceListViewModel extends ChangeNotifier {
  InvoiceListViewModel(this._repo, [this._backupService]) {
    _invoicesSub = _repo.watchSavedInvoices().listen((invoices) {
      _invoices  = invoices;
      _isLoading = false;
      notifyListeners();
    });
    _draftSub = _repo.watchDraft().listen((draft) {
      _draft = draft;
      notifyListeners();
    });
    if (_backupService != null) refreshBackupStatus();
  }

  final IInvoiceRepository _repo;
  final BackupService?     _backupService;

  late final StreamSubscription<List<Invoice>> _invoicesSub;
  late final StreamSubscription<Invoice?>      _draftSub;

  List<Invoice> _invoices = const [];
  Invoice?      _draft;
  bool          _isLoading          = true;
  String?       _error;
  DateTime?     _lastBackupAt;
  bool          _backupStatusLoaded = false;

  List<Invoice> get invoices  => _invoices;
  Invoice?      get draft     => _draft;
  bool          get isLoading => _isLoading;
  String?       get error     => _error;

  /// True when a backup reminder banner should be shown:
  /// never backed up OR last backup > 3 days ago.
  bool get shouldShowBackupReminder {
    if (_backupService == null || !_backupStatusLoaded) return false;
    if (_lastBackupAt == null) return true;
    return DateTime.now().difference(_lastBackupAt!).inDays >= 3;
  }

  /// Human-readable label for the reminder banner.
  String get backupReminderMessage {
    if (_lastBackupAt == null) return 'Jamais sauvegardé.';
    final days = DateTime.now().difference(_lastBackupAt!).inDays;
    return 'Dernière sauvegarde il y a $days jour${days > 1 ? 's' : ''}.';
  }

  /// Reads the last backup timestamp. Call on init and after returning
  /// from BackupScreen so the banner hides when a backup was just done.
  Future<void> refreshBackupStatus() async {
    _lastBackupAt       = await _backupService?.getLastBackupDate();
    _backupStatusLoaded = true;
    notifyListeners();
  }

  /// Creates a new draft and returns it for navigation to the detail screen.
  /// Returns null on failure ([error] set).
  Future<Invoice?> createDraft({
    required DateTime issueDate,
    required String location,
    required double basePrice,
  }) async {
    _error = null;
    try {
      return await _repo.createDraft(
        issueDate: issueDate,
        location:  location,
        basePrice: basePrice,
      );
    } on BusinessException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  /// DraftBanner "Discard" — cascade-deletes the draft and its lines.
  Future<void> discardDraft() async {
    final draft = _draft;
    if (draft == null) return;
    _error = null;
    try {
      await _repo.discardDraft(draft.id);
    } on BusinessException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _invoicesSub.cancel();
    _draftSub.cancel();
    super.dispose();
  }
}
