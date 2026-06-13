import 'package:drift/drift.dart';

import 'invoices_table.dart';

/// Drift table for invoice lines (one row = one gold bar).
///
/// Calculated columns (density, carat, unitPrice, amount) are stored
/// as computed at entry time — never recomputed on read.
@DataClassName('InvoiceLineRow')
class InvoiceLines extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Cascade delete: discarding a draft invoice removes its lines.
  IntColumn get invoiceId =>
      integer().references(Invoices, #id, onDelete: KeyAction.cascade)();

  /// Position of the bar in the invoice: 1, 2, 3...
  IntColumn get barNumber => integer()();

  RealColumn get basePrice => real()();
  RealColumn get grossWeight => real()();
  RealColumn get waterWeight => real()();
  RealColumn get density => real()();
  RealColumn get carat => real()();
  RealColumn get unitPrice => real()();
  RealColumn get amount => real()();
}
