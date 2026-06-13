import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/business_exceptions.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/i_invoice_repository.dart';

/// State for InvoiceListScreen: saved invoices + the draft (DraftBanner),
/// creation of a new draft and discarding the current one.
class InvoiceListViewModel extends ChangeNotifier {
  InvoiceListViewModel(this._repo) {
    _invoicesSub = _repo.watchSavedInvoices().listen((invoices) {
      _invoices = invoices;
      _isLoading = false;
      notifyListeners();
    });
    _draftSub = _repo.watchDraft().listen((draft) {
      _draft = draft;
      notifyListeners();
    });
  }

  final IInvoiceRepository _repo;

  late final StreamSubscription<List<Invoice>> _invoicesSub;
  late final StreamSubscription<Invoice?> _draftSub;

  List<Invoice> _invoices = const [];
  Invoice? _draft;
  bool _isLoading = true;
  String? _error;

  List<Invoice> get invoices => _invoices;

  /// Non-null when an unfinished invoice exists — drives the DraftBanner.
  Invoice? get draft => _draft;

  bool get isLoading => _isLoading;

  String? get error => _error;

  /// Creates a new draft and returns it so the view can navigate to the
  /// detail screen. Returns null on failure (error exposed via [error]).
  Future<Invoice?> createDraft({
    required DateTime issueDate,
    required String location,
    required double basePrice,
  }) async {
    _error = null;
    try {
      return await _repo.createDraft(
        issueDate: issueDate,
        location: location,
        basePrice: basePrice,
      );
    } on BusinessException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  /// DraftBanner "Discard": deletes the draft and its lines.
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
