import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_line_preview.freezed.dart';

/// Transient result of the real-time calculation preview shown in the
/// line entry form while the operator types — never persisted.
@freezed
abstract class InvoiceLinePreview with _$InvoiceLinePreview {
  const factory InvoiceLinePreview({
    required double density,
    required double carat,
    required double unitPrice,
    required double amount,
  }) = _InvoiceLinePreview;
}
