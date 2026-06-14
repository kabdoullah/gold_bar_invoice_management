import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_line.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/services/print_service.dart';

/// State for [InvoiceHistoryScreen] and the read-only
/// [InvoiceDetailScreen].
///
/// Watches the saved-invoices stream for the list, and lazily loads the
/// selected invoice + its lines when the detail route is opened. Reprint
/// regenerates the PDF straight from the stored values — never recomputes.
class InvoiceHistoryViewModel extends ChangeNotifier {
  InvoiceHistoryViewModel(this._repo, this._printService) {
    _invoicesSub = _repo.watchSavedInvoices().listen((invoices) {
      _savedInvoices = invoices;
      _isLoading     = false;
      notifyListeners();
    });
  }

  final IInvoiceRepository _repo;
  final PrintService       _printService;

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

  @override
  void dispose() {
    _invoicesSub.cancel();
    super.dispose();
  }
}
