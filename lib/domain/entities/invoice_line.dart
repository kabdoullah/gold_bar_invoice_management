import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_line.freezed.dart';

/// One row of an invoice = one weighed gold bar.
///
/// The calculated values (`density`, `carat`, `unitPrice`, `amount`) are
/// computed once by `GoldBarCalculatorService` when the line is added and
/// stored as-is — they are never recomputed on read, so historical invoices
/// stay stable even if business constants ever change.
@freezed
abstract class InvoiceLine with _$InvoiceLine {
  const factory InvoiceLine({
    required int id,
    required int invoiceId,

    /// Position of the bar in the invoice: 1, 2, 3...
    required int barNumber,

    /// Market base price at the time the line was entered.
    required double basePrice,

    /// Weight of the bar in grams, in air ("Poids brut").
    required double grossWeight,

    /// Weight of the bar submerged in water ("Eaux") — hydrostatic method.
    required double waterWeight,

    /// grossWeight / waterWeight, truncated to 2 decimals.
    required double density,

    /// Gold purity, derived from density. Always displayed in red.
    required double carat,

    /// Price per gram for this bar ("U/BASE").
    required double unitPrice,

    /// Line total: unitPrice × grossWeight ("Montant").
    required double amount,
  }) = _InvoiceLine;
}

/// Raw-sum totals over a set of lines, used by the on-screen totals block
/// and the PDF. Density/carat are per-bar values not stored on [Invoice],
/// so they are summed on the fly here (single source of truth).
extension InvoiceLineTotals on List<InvoiceLine> {
  double get totalDensity => fold(0.0, (sum, line) => sum + line.density);

  double get totalCarat => fold(0.0, (sum, line) => sum + line.carat);
}
