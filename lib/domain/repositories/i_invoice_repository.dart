import '../entities/invoice.dart';
import '../entities/invoice_line.dart';

/// Persistence contract for invoices and their lines.
///
/// Implementations own all orchestration: calculation of stored line
/// values, denormalized totals refresh, status transitions and sync
/// enqueueing — ViewModels never talk to the database directly.
abstract interface class IInvoiceRepository {
  /// Saved invoices for the list screen, newest first.
  Stream<List<Invoice>> watchSavedInvoices();

  Future<Invoice?> getInvoice(int id);

  Stream<Invoice?> watchInvoice(int id);

  /// The single unfinished invoice, if any (DraftBanner).
  Future<Invoice?> findDraft();

  Stream<Invoice?> watchDraft();

  /// Creates a draft invoice, persisted immediately so an accidental
  /// app closure loses nothing.
  ///
  /// Throws `InvoiceStateException` if a draft already exists — the app
  /// allows only one at a time.
  Future<Invoice> createDraft({
    required DateTime issueDate,
    required String location,
    required double basePrice,
  });

  /// Edits the header of a draft (location, issueDate, basePrice).
  ///
  /// Throws `InvoiceStateException` if the invoice is not a draft, or if
  /// [basePrice] is changed while lines exist (stored line amounts would
  /// no longer match the header).
  Future<void> updateDraftHeader(
    int id, {
    DateTime? issueDate,
    String? location,
    double? basePrice,
  });

  /// Lines of an invoice in bar order.
  Future<List<InvoiceLine>> getLines(int invoiceId);

  Stream<List<InvoiceLine>> watchLines(int invoiceId);

  /// Calculates density/carat/unitPrice/amount, inserts the line and
  /// refreshes the invoice totals — atomically.
  ///
  /// Throws `InvoiceStateException` if the invoice is not a draft.
  Future<InvoiceLine> addLine({
    required int invoiceId,
    required double grossWeight,
    required double waterWeight,
  });

  /// Re-prices an existing line from new [grossWeight]/[waterWeight] (inline
  /// editing of a saved invoice), then refreshes the invoice totals —
  /// atomically. Recomputes density/carat/unitPrice/amount with the invoice's
  /// locked basePrice; `barNumber`, `basePrice` and `status` are unchanged.
  Future<InvoiceLine> updateLine({
    required int lineId,
    required int invoiceId,
    required double grossWeight,
    required double waterWeight,
  });

  /// Changes the [basePrice] of a saved invoice and **re-prices every line**
  /// with it (unitPrice + amount recomputed; density/carat are
  /// base-independent and stay), then refreshes the invoice totals — all in
  /// one transaction. `status` and bar count are unchanged.
  ///
  /// Throws `InvalidBasePriceException` if [basePrice] is not strictly
  /// positive.
  Future<void> updateInvoiceBasePrice({
    required int invoiceId,
    required double basePrice,
  });

  /// Deletes a line and refreshes the invoice totals — atomically.
  Future<void> deleteLine({required int lineId, required int invoiceId});

  /// Finalizes a draft: status → saved, updatedAt refreshed.
  Future<void> finalizeInvoice(int id);

  /// Deletes a draft invoice and its lines (DraftBanner "Discard").
  Future<void> discardDraft(int id);
}
