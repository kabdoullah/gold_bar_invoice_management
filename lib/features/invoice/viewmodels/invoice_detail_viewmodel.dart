import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/business_exceptions.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_line.dart';
import '../../../domain/entities/invoice_line_preview.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/services/gold_bar_calculator_service.dart';
import '../../../domain/services/print_service.dart';

/// State for InvoiceDetailScreen: the invoice header, its lines, the
/// real-time entry preview, line mutations and Save & Print.
class InvoiceDetailViewModel extends ChangeNotifier {
  InvoiceDetailViewModel(
    this._repo,
    this._calculator,
    this._printService, {
    required int invoiceId,
  }) {
    _invoiceSub = _repo.watchInvoice(invoiceId).listen((invoice) {
      _invoice = invoice;
      _isLoading = false;
      notifyListeners();
    });
    _linesSub = _repo.watchLines(invoiceId).listen((lines) {
      _lines = lines;
      notifyListeners();
    });
  }

  final IInvoiceRepository _repo;
  final GoldBarCalculatorService _calculator;
  final PrintService _printService;

  late final StreamSubscription<Invoice?> _invoiceSub;
  late final StreamSubscription<List<InvoiceLine>> _linesSub;

  Invoice? _invoice;
  List<InvoiceLine> _lines = const [];
  bool _isLoading = true;
  bool _isSavingAndPrinting = false;
  String? _error;

  Invoice? get invoice => _invoice;

  List<InvoiceLine> get lines => _lines;

  bool get isLoading => _isLoading;

  bool get isSavingAndPrinting => _isSavingAndPrinting;

  String? get error => _error;

  /// Save & Print is only available on a draft with at least one line.
  bool get canSaveAndPrint =>
      !_isSavingAndPrinting && (_invoice?.isDraft ?? false) && _lines.isNotEmpty;

  /// Real-time preview during input — persists nothing, called on every
  /// keystroke. Returns null while the inputs are not yet valid (zero,
  /// negative, water >= gross) so the form can show an empty preview.
  InvoiceLinePreview? previewLine(double grossWeight, double waterWeight) {
    final invoice = _invoice;
    if (invoice == null) return null;
    try {
      return _calculator.calculateLine(
        grossWeight: grossWeight,
        waterWeight: waterWeight,
        basePrice: invoice.basePrice,
      );
    } on BusinessException {
      return null;
    }
  }

  /// Persists the line immediately (draft safety); totals refresh and the
  /// watch streams push the new state.
  Future<bool> addLine(double grossWeight, double waterWeight) {
    return _guard(() => _repo.addLine(
          invoiceId: _requireInvoice().id,
          grossWeight: grossWeight,
          waterWeight: waterWeight,
        ));
  }

  Future<bool> deleteLine(int lineId) {
    return _guard(() => _repo.deleteLine(
          lineId: lineId,
          invoiceId: _requireInvoice().id,
        ));
  }

  /// Header edits while drafting (location, issue date).
  Future<bool> updateHeader({DateTime? issueDate, String? location}) {
    return _guard(() => _repo.updateDraftHeader(
          _requireInvoice().id,
          issueDate: issueDate,
          location: location,
        ));
  }

  /// Finalizes the invoice: status draft → saved, enqueues for sync,
  /// generates the PDF and opens the native print/share sheet.
  Future<bool> saveAndPrint() async {
    final invoice = _invoice;
    if (invoice == null) return false;
    _isSavingAndPrinting = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.finalizeInvoice(invoice.id);
      await _repo.enqueueForSync(invoice.id);
      final updated = await _repo.getInvoice(invoice.id);
      await _printService.printInvoice(updated ?? invoice, _lines);
      return true;
    } on BusinessException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSavingAndPrinting = false;
      notifyListeners();
    }
  }

  Future<bool> _guard(Future<void> Function() action) async {
    _error = null;
    try {
      await action();
      return true;
    } on BusinessException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Invoice _requireInvoice() {
    final invoice = _invoice;
    if (invoice == null) {
      throw const InvoiceStateException('Invoice not loaded yet');
    }
    return invoice;
  }

  @override
  void dispose() {
    _invoiceSub.cancel();
    _linesSub.cancel();
    super.dispose();
  }
}
