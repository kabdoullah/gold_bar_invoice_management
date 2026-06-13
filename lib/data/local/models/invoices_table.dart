import 'package:drift/drift.dart';

/// Drift table for invoices.
///
/// Row class is named [InvoiceRow] to avoid clashing with the domain
/// entity `Invoice` — repositories map between the two.
@DataClassName('InvoiceRow')
class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  DateTimeColumn get issueDate => dateTime()();
  TextColumn get location => text().withDefault(const Constant('Bamako'))();
  RealColumn get basePrice => real()();

  /// 'draft' | 'saved' — see domain `InvoiceStatus.dbValue`.
  TextColumn get status => text().withDefault(const Constant('draft'))();

  IntColumn get barCount => integer().withDefault(const Constant(0))();
  RealColumn get totalGrossWeight => real().withDefault(const Constant(0))();
  RealColumn get totalWaterWeight => real().withDefault(const Constant(0))();
  RealColumn get totalAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
