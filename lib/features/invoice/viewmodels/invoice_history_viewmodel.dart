import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/business_exceptions.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_line.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/services/gold_bar_calculator_service.dart';
import '../../../domain/services/print_service.dart';

/// State for [InvoiceHistoryScreen] and the editable [InvoiceDetailScreen].
///
/// Watches the saved-invoices stream for the list, and lazily loads the
/// selected invoice + its lines when the detail route is opened. The detail
/// view edits the Poids/Eaux values of existing lines (no add, no delete):
/// each edit goes through the repository's atomic [updateLine] (which
/// re-prices the line and refreshes the denormalized totals), then reloads
/// the selection from storage so the totals row and global carat reflect the
/// new state. basePrice, invoiceNumber and the bar count never change on
/// edit. Reprint regenerates the PDF straight from the stored values — never
/// recomputes — and is manual (no auto-reprint after an edit).
class InvoiceHistoryViewModel extends ChangeNotifier {
  InvoiceHistoryViewModel(this._repo, this._printService, this._calculator) {
    _invoicesSub = _repo.watchSavedInvoices().listen((invoices) {
      _savedInvoices = invoices;
      _isLoading     = false;
      notifyListeners();
    });
  }

  final IInvoiceRepository       _repo;
  final PrintService             _printService;
  final GoldBarCalculatorService _calculator;

  late final StreamSubscription<List<Invoice>> _invoicesSub;

  List<Invoice> _savedInvoices = const [];
  bool          _isLoading     = true;

  Invoice?          _selectedInvoice;
  List<InvoiceLine> _selectedLines   = const [];
  bool              _isLoadingDetail = false;
  bool              _isReprinting    = false;
  String?           _reprintError;

  List<Invoice> get savedInvoices => _savedInvoices;

  bool get isLoading => _isLoading;

  Invoice? get selectedInvoice => _selectedInvoice;

  List<InvoiceLine> get selectedLines => _selectedLines;

  /// Invoice-level "Densité Totale" / "Carat Général" for the selected
  /// invoice, recomputed from its stored raw totals — never a sum of lines.
  /// Zeros when nothing is selected.
  GlobalCaratResult get globalCaratResult {
    final inv = _selectedInvoice;
    if (inv == null) {
      return const GlobalCaratResult(globalDensity: 0, globalCarat: 0);
    }
    return _calculator.calculateGlobalCarat(
      totalGrossWeight: inv.totalGrossWeight,
      totalWaterWeight: inv.totalWaterWeight,
    );
  }

  /// True while a new selection's invoice + lines are being fetched. The
  /// previous selection stays visible meanwhile (no blank flash).
  bool get isLoadingDetail => _isLoadingDetail;

  bool get isReprinting => _isReprinting;

  /// Last reprint failure message, or null if the last reprint succeeded.
  String? get reprintError => _reprintError;

  /// Loads the invoice + its lines for the detail view. Keeps the previous
  /// selection on screen while loading (flag [isLoadingDetail]) rather than
  /// blanking it — avoids an empty-pane flash when switching invoices. The
  /// mobile detail screen still gates on the id, so it shows its loader until
  /// the requested invoice arrives.
  Future<void> selectInvoice(int id) async {
    _isLoadingDetail = true;
    notifyListeners();
    final invoice = await _repo.getInvoice(id);
    final lines   = await _repo.getLines(id);
    _selectedInvoice = invoice;
    _selectedLines   = lines;
    _isLoadingDetail = false;
    notifyListeners();
  }

  /// Regenerates the PDF from stored data and opens the native print
  /// sheet. No recalculation — historical amounts stay byte-for-byte.
  ///
  /// Returns true on success. On failure, stores the message in
  /// [reprintError] and returns false (never rethrows to the caller).
  Future<bool> reprintInvoice(Invoice invoice, List<InvoiceLine> lines) async {
    if (_isReprinting) return false;
    _isReprinting = true;
    _reprintError = null;
    notifyListeners();
    try {
      await _printService.printInvoice(invoice, lines);
      return true;
    } catch (e) {
      _reprintError = e.toString();
      return false;
    } finally {
      _isReprinting = false;
      notifyListeners();
    }
  }

  // ── Editing a saved invoice (line values only) ────────────────────

  bool    _isMutating = false;
  String? _editError;

  /// True while a line edit is being persisted + reloaded.
  bool get isMutating => _isMutating;

  /// Last edit failure message, or null on success.
  String? get editError => _editError;

  /// Re-prices an existing line of the currently selected saved invoice from
  /// new [grossWeight]/[waterWeight] (inline editing). The repository
  /// recomputes the derived values and refreshes the invoice totals
  /// atomically; we then reload the selection. basePrice, invoiceNumber and
  /// the bar count stay unchanged. Returns true on success; on an invalid
  /// pair (e.g. water >= gross) stores the message in [editError] and
  /// returns false (the table then reverts the field).
  Future<bool> updateLineInSelectedInvoice(
    int lineId,
    double grossWeight,
    double waterWeight,
  ) async {
    final inv = _selectedInvoice;
    if (inv == null || _isMutating) return false;
    _isMutating = true;
    _editError  = null;
    notifyListeners();
    try {
      await _repo.updateLine(
        lineId:      lineId,
        invoiceId:   inv.id,
        grossWeight: grossWeight,
        waterWeight: waterWeight,
      );
      await selectInvoice(inv.id);
      return true;
    } on BusinessException catch (e) {
      _editError = e.message;
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  /// Changes the base price of the currently selected saved invoice and
  /// re-prices all its lines (repository does it atomically), then reloads.
  /// Returns true on success; on an invalid price stores the message in
  /// [editError] and returns false (the field then reverts).
  Future<bool> updateBasePriceOfSelectedInvoice(double basePrice) async {
    final inv = _selectedInvoice;
    if (inv == null || _isMutating) return false;
    if (basePrice == inv.basePrice) return true; // unchanged, no-op
    _isMutating = true;
    _editError  = null;
    notifyListeners();
    try {
      await _repo.updateInvoiceBasePrice(
        invoiceId: inv.id,
        basePrice: basePrice,
      );
      await selectInvoice(inv.id);
      return true;
    } on BusinessException catch (e) {
      _editError = e.message;
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _invoicesSub.cancel();
    super.dispose();
  }
}
