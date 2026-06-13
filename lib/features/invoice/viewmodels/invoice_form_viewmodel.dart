import 'package:flutter/foundation.dart';

import '../../../core/constants/business_constants.dart';
import '../../../core/errors/business_exceptions.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/i_invoice_repository.dart';

/// State for InvoiceFormScreen: header fields of a new invoice and
/// creation of the draft.
class InvoiceFormViewModel extends ChangeNotifier {
  InvoiceFormViewModel(this._repo);

  final IInvoiceRepository _repo;

  DateTime issueDate = DateTime.now();
  String location = BusinessConstants.defaultLocation;
  double? basePrice;
  bool isSubmitting = false;
  String? error;

  bool get canSubmit =>
      !isSubmitting && (basePrice ?? 0) > 0 && location.trim().isNotEmpty;

  void setIssueDate(DateTime value) {
    issueDate = value;
    notifyListeners();
  }

  void setLocation(String value) {
    location = value;
    notifyListeners();
  }

  void setBasePrice(double? value) {
    basePrice = value;
    notifyListeners();
  }

  /// Creates the draft and returns it for navigation to the detail
  /// screen. Null on failure, with [error] set.
  Future<Invoice?> submit() async {
    if (!canSubmit) return null;
    isSubmitting = true;
    error = null;
    notifyListeners();
    try {
      return await _repo.createDraft(
        issueDate: issueDate,
        location: location.trim(),
        basePrice: basePrice!,
      );
    } on BusinessException catch (e) {
      error = e.message;
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
