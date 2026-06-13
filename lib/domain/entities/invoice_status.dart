/// Represents the lifecycle state of an invoice.
enum InvoiceStatus {
  /// Invoice is being built — lines are being added.
  /// Persisted immediately to Drift to survive accidental app closure.
  draft('draft'),

  /// Invoice is finalized — saved, printed, and enqueued for cloud sync.
  saved('saved');

  const InvoiceStatus(this.dbValue);

  /// Value stored in the `invoices.status` text column.
  final String dbValue;

  static InvoiceStatus fromDb(String value) => values.firstWhere(
        (status) => status.dbValue == value,
        orElse: () => throw ArgumentError('Unknown invoice status: $value'),
      );
}
