import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/invoices_table.dart';

part 'invoice_dao.g.dart';

/// Data access for the `invoices` table. No business logic here —
/// orchestration (totals recalculation, sync enqueueing) lives in the
/// repository.
@DriftAccessor(tables: [Invoices])
class InvoiceDao extends DatabaseAccessor<AppDatabase> with _$InvoiceDaoMixin {
  InvoiceDao(super.db);

  /// Saved invoices for the list screen, newest first.
  Stream<List<InvoiceRow>> watchSaved() {
    return (select(invoices)
          ..where((i) => i.status.equals('saved'))
          ..orderBy([
            (i) => OrderingTerm.desc(i.issueDate),
            (i) => OrderingTerm.desc(i.id),
          ]))
        .watch();
  }

  Future<InvoiceRow?> getById(int id) {
    return (select(invoices)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  Stream<InvoiceRow?> watchById(int id) {
    return (select(invoices)..where((i) => i.id.equals(id)))
        .watchSingleOrNull();
  }

  /// The unfinished invoice, if any. The app never creates more than one
  /// draft at a time.
  Future<InvoiceRow?> findDraft() {
    return (select(invoices)..where((i) => i.status.equals('draft')))
        .getSingleOrNull();
  }

  Stream<InvoiceRow?> watchDraft() {
    return (select(invoices)..where((i) => i.status.equals('draft')))
        .watchSingleOrNull();
  }

  /// Highest existing id, used to derive the next invoice number.
  Future<int> maxId() async {
    final maxIdExp = invoices.id.max();
    final query = selectOnly(invoices)..addColumns([maxIdExp]);
    final row = await query.getSingle();
    return row.read(maxIdExp) ?? 0;
  }

  Future<int> insertInvoice(InvoicesCompanion entry) {
    return into(invoices).insert(entry);
  }

  Future<void> updateFields(int id, InvoicesCompanion entry) async {
    await (update(invoices)..where((i) => i.id.equals(id))).write(entry);
  }

  /// Cascade delete removes the invoice's lines (PRAGMA foreign_keys ON).
  Future<void> deleteById(int id) async {
    await (delete(invoices)..where((i) => i.id.equals(id))).go();
  }
}
