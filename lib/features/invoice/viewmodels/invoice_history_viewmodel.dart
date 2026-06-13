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
  List<InvoiceLine> _selectedLines = const [];
  bool              _isReprinting  = false;

  List<Invoice> get savedInvoices => _savedInvoices;

  bool get isLoading => _isLoading;

  Invoice? get selectedInvoice => _selectedInvoice;

  List<InvoiceLine> get selectedLines => _selectedLines;

  bool get isReprinting => _isReprinting;

  /// Loads the invoice + its lines for the detail view. Clears any prior
  /// selection first so the screen shows a loader rather than stale data.
  Future<void> selectInvoice(int id) async {
    _selectedInvoice = null;
    _selectedLines   = const [];
    notifyListeners();
    final invoice = await _repo.getInvoice(id);
    final lines   = await _repo.getLines(id);
    _selectedInvoice = invoice;
    _selectedLines   = lines;
    notifyListeners();
  }

  /// Regenerates the PDF from stored data and opens the native print
  /// sheet. No recalculation — historical amounts stay byte-for-byte.
  Future<void> reprintInvoice(Invoice invoice, List<InvoiceLine> lines) async {
    if (_isReprinting) return;
    _isReprinting = true;
    notifyListeners();
    try {
      await _printService.printInvoice(invoice, lines);
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
