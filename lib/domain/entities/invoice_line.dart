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
    DateTime? syncedAt,
  }) = _InvoiceLine;
}
