import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/business_constants.dart';
import '../../../core/errors/business_exceptions.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_line.dart';
import '../../../domain/entities/invoice_line_preview.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/services/backup_service.dart';
import '../../../domain/services/gold_bar_calculator_service.dart';
import '../../../domain/services/print_service.dart';

/// State for [InvoiceEntryScreen] — the single home screen.
///
/// Merges the concerns of the old InvoiceForm + InvoiceDetail VMs:
/// shared base price, gross/water entry, real-time preview, lazy draft
/// lifecycle, the line list and Save & Print. Also owns the backup
/// reminder state shown by the banner and the AppBar status dot.
///
/// Draft lifecycle:
/// - On init, an existing draft (survived an app kill) is auto-loaded so
///   the operator can keep going where they left off.
/// - Otherwise the draft is created lazily on the first "Ajouter barre",
///   so an empty session never persists a junk invoice.
/// - After "Enregistrer & Imprimer" everything resets for a brand new
///   invoice — base price included.
class InvoiceEntryViewModel extends ChangeNotifier {
  InvoiceEntryViewModel(
    this._repo,
    this._calculator,
    this._printService, [
    this._backupService,
  ]) {
    _loadExistingDraft();
    if (_backupService != null) refreshBackupStatus();
  }

  final IInvoiceRepository       _repo;
  final GoldBarCalculatorService _calculator;
  final PrintService             _printService;
  final BackupService?           _backupService;

  StreamSubscription<Invoice?>?            _invoiceSub;
  StreamSubscription<List<InvoiceLine>>?   _linesSub;

  Invoice?          _draft;
  List<InvoiceLine> _lines = const [];
  double?           _basePrice;
  double?           _grossWeight;
  double?           _waterWeight;
  bool              _isSavingAndPrinting = false;
  String?           _error;

  DateTime? _lastBackupAt;
  bool      _backupStatusLoaded = false;

  // ── Public state ──────────────────────────────────────────────────

  /// The draft invoice once it exists (lazy). Null before the first line
  /// and after a successful Save & Print. Used for the totals row.
  Invoice? get invoice => _draft;

  List<InvoiceLine> get lines => _lines;

  double? get basePrice => _basePrice;

  bool get isSavingAndPrinting => _isSavingAndPrinting;

  String? get error => _error;

  /// Real-time preview of the line currently being typed. Null while the
  /// inputs are empty or invalid (zero, negative, water >= gross), so the
  /// form shows placeholders.
  InvoiceLinePreview? get currentPreview {
    final bp = _basePrice;
    final g  = _grossWeight;
    final w  = _waterWeight;
    if (bp == null || g == null || w == null) return null;
    try {
      return _calculator.calculateLine(
        grossWeight: g,
        waterWeight: w,
        basePrice: bp,
      );
    } on BusinessException {
      return null;
    }
  }

  /// "Ajouter barre" is enabled only when the preview is valid.
  bool get canAddLine => !_isSavingAndPrinting && currentPreview != null;

  /// "Enregistrer & Imprimer" needs at least one persisted line.
  bool get canSaveAndPrint => !_isSavingAndPrinting && _lines.isNotEmpty;

  // ── Inputs ────────────────────────────────────────────────────────

  void setBasePrice(double? value) {
    // Once lines exist the basePrice is locked (stored line amounts depend
    // on it). Ignore edits so the in-memory value keeps reflecting the
    // locked truth instead of going blank under the operator.
    if (_lines.isNotEmpty) return;
    _basePrice = value;
    // Keep a freshly-created (still empty) draft's header in sync.
    if (_draft != null && value != null && value > 0) {
      // ignore: unawaited_futures
      _repo.updateDraftHeader(_draft!.id, basePrice: value);
    }
    notifyListeners();
  }

  void setGrossWeight(double? value) {
    _grossWeight = value;
    notifyListeners();
  }

  void setWaterWeight(double? value) {
    _waterWeight = value;
    notifyListeners();
  }

  /// Clears the gross/water inputs (base price stays). Called by the view
  /// after a line is added; idempotent with [addLine]'s own reset.
  void clearWeightInputs() {
    _grossWeight = null;
    _waterWeight = null;
    notifyListeners();
  }

  // ── Mutations ─────────────────────────────────────────────────────

  /// Persists the current preview as a line. Creates the draft lazily on
  /// the first call. On success the gross/water inputs are cleared while
  /// the base price persists for the next bar.
  Future<bool> addLine() async {
    if (!canAddLine) return false;
    _error = null;
    try {
      if (_draft == null) {
        final draft = await _repo.createDraft(
          issueDate: DateTime.now(),
          location:  BusinessConstants.defaultLocation,
          basePrice: _basePrice!,
        );
        _draft = draft;
        _attachDraftStreams(draft.id);
      }
      await _repo.addLine(
        invoiceId:   _draft!.id,
        grossWeight: _grossWeight!,
        waterWeight: _waterWeight!,
      );
      _grossWeight = null;
      _waterWeight = null;
      notifyListeners();
      return true;
    } on BusinessException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Removes a line from the current draft (totals refresh via stream).
  Future<bool> deleteLine(int lineId) async {
    final draft = _draft;
    if (draft == null) return false;
    _error = null;
    try {
      await _repo.deleteLine(lineId: lineId, invoiceId: draft.id);
      return true;
    } on BusinessException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Finalizes the draft, generates the PDF and opens the native print
  /// sheet, then fires a silent auto-backup and resets the screen for a
  /// new invoice. Never throws to the view.
  Future<bool> saveAndPrint() async {
    final draft = _draft;
    if (draft == null || _lines.isEmpty) return false;
    _isSavingAndPrinting = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.finalizeInvoice(draft.id);
      final saved = await _repo.getInvoice(draft.id);
      final lines = _lines;
      await _printService.printInvoice(saved ?? draft, lines);
      // ignore: unawaited_futures
      _backupService?.autoBackupIfConnected();
      _resetForNewInvoice();
      // ignore: unawaited_futures
      refreshBackupStatus();
      return true;
    } on BusinessException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSavingAndPrinting = false;
      notifyListeners();
    }
  }

  // ── Backup reminder (mirrors InvoiceListViewModel) ────────────────

  /// True when a reminder is due: never backed up, or > 3 days ago.
  bool get shouldShowBackupReminder {
    if (_backupService == null || !_backupStatusLoaded) return false;
    if (_lastBackupAt == null) return true;
    return DateTime.now().difference(_lastBackupAt!).inDays >= 3;
  }

  String get backupReminderMessage {
    if (_lastBackupAt == null) return 'Aucune sauvegarde effectuée.';
    final days = DateTime.now().difference(_lastBackupAt!).inDays;
    if (days == 0) return 'Sauvegardé aujourd\'hui.';
    return 'Dernière sauvegarde il y a $days jour${days > 1 ? 's' : ''}.';
  }

  /// Re-reads the last backup timestamp. Call after returning from the
  /// BackupScreen so the banner/dot update.
  Future<void> refreshBackupStatus() async {
    _lastBackupAt       = await _backupService?.getLastBackupDate();
    _backupStatusLoaded = true;
    notifyListeners();
  }

  // ── Internals ─────────────────────────────────────────────────────

  Future<void> _loadExistingDraft() async {
    final draft = await _repo.findDraft();
    if (draft == null) return;
    _draft     = draft;
    _basePrice = draft.basePrice;
    _attachDraftStreams(draft.id);
    notifyListeners();
  }

  void _attachDraftStreams(int id) {
    _invoiceSub?.cancel();
    _linesSub?.cancel();
    _invoiceSub = _repo.watchInvoice(id).listen((inv) {
      _draft = inv;
      notifyListeners();
    });
    _linesSub = _repo.watchLines(id).listen((lines) {
      _lines = lines;
      notifyListeners();
    });
  }

  void _resetForNewInvoice() {
    _invoiceSub?.cancel();
    _linesSub?.cancel();
    _invoiceSub  = null;
    _linesSub    = null;
    _draft       = null;
    _lines       = const [];
    _basePrice   = null;
    _grossWeight = null;
    _waterWeight = null;
  }

  @override
  void dispose() {
    _invoiceSub?.cancel();
    _linesSub?.cancel();
    super.dispose();
  }
}
