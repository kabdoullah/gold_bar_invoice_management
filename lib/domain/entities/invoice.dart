import 'package:freezed_annotation/freezed_annotation.dart';

import 'invoice_status.dart';

part 'invoice.freezed.dart';

/// A gold bar sale invoice (pure Dart entity — no persistence concerns).
///
/// Totals (`barCount`, `totalGrossWeight`, `totalWaterWeight`, `totalAmount`)
/// are denormalized: recalculated and persisted by the repository every time
/// a line is added or deleted, never computed in the UI.
@freezed
abstract class Invoice with _$Invoice {
  const Invoice._();

  const factory Invoice({
    required int id,
    required String invoiceNumber,
    required DateTime issueDate,
    required String location,

    /// Reference market price ("Base"), shared by every line of this invoice.
    required double basePrice,
    required InvoiceStatus status,
    required int barCount,
    required double totalGrossWeight,
    required double totalWaterWeight,
    required double totalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,

    /// Null until the invoice has been pushed to Supabase.
    DateTime? syncedAt,
  }) = _Invoice;

  bool get isDraft => status == InvoiceStatus.draft;

  bool get isSynced => syncedAt != null;
}
