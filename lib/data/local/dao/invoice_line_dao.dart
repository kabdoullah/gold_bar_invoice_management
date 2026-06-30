import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/invoice_lines_table.dart';

part 'invoice_line_dao.g.dart';

/// Totals aggregated over the lines of one invoice, used by the
/// repository to refresh the denormalized columns on `invoices`.
class InvoiceLineTotals {
  const InvoiceLineTotals({
    required this.barCount,
    required this.totalGrossWeight,
    required this.totalWaterWeight,
    required this.totalAmount,
  });

  final int barCount;
  final double totalGrossWeight;
  final double totalWaterWeight;
  final double totalAmount;
}

/// Data access for the `invoice_lines` table.
@DriftAccessor(tables: [InvoiceLines])
class InvoiceLineDao extends DatabaseAccessor<AppDatabase>
    with _$InvoiceLineDaoMixin {
  InvoiceLineDao(super.db);

  /// Lines of an invoice in bar order (1, 2, 3...).
  Future<List<InvoiceLineRow>> getForInvoice(int invoiceId) {
    return (select(invoiceLines)
          ..where((l) => l.invoiceId.equals(invoiceId))
          ..orderBy([(l) => OrderingTerm.asc(l.barNumber)]))
        .get();
  }

  Stream<List<InvoiceLineRow>> watchForInvoice(int invoiceId) {
    return (select(invoiceLines)
          ..where((l) => l.invoiceId.equals(invoiceId))
          ..orderBy([(l) => OrderingTerm.asc(l.barNumber)]))
        .watch();
  }

  Future<int> insertLine(InvoiceLinesCompanion entry) {
    return into(invoiceLines).insert(entry);
  }

  Future<void> deleteById(int id) async {
    await (delete(invoiceLines)..where((l) => l.id.equals(id))).go();
  }

  /// Overwrites the editable/derived columns of one line (used by inline
  /// editing on a saved invoice). `barNumber`, `invoiceId` and `basePrice`
  /// are not touched by the caller's companion.
  Future<void> updateLineValues(int id, InvoiceLinesCompanion entry) async {
    await (update(invoiceLines)..where((l) => l.id.equals(id))).write(entry);
  }

  /// Next bar number for an invoice: max(barNumber) + 1, starting at 1.
  Future<int> nextBarNumber(int invoiceId) async {
    final maxBar = invoiceLines.barNumber.max();
    final query = selectOnly(invoiceLines)
      ..addColumns([maxBar])
      ..where(invoiceLines.invoiceId.equals(invoiceId));
    final row = await query.getSingle();
    return (row.read(maxBar) ?? 0) + 1;
  }

  /// SQL-side aggregation of the denormalized invoice totals.
  Future<InvoiceLineTotals> totalsForInvoice(int invoiceId) async {
    final count = invoiceLines.id.count();
    final gross = invoiceLines.grossWeight.sum();
    final water = invoiceLines.waterWeight.sum();
    final amount = invoiceLines.amount.sum();
    final query = selectOnly(invoiceLines)
      ..addColumns([count, gross, water, amount])
      ..where(invoiceLines.invoiceId.equals(invoiceId));
    final row = await query.getSingle();
    return InvoiceLineTotals(
      barCount: row.read(count) ?? 0,
      totalGrossWeight: row.read(gross) ?? 0,
      totalWaterWeight: row.read(water) ?? 0,
      totalAmount: row.read(amount) ?? 0,
    );
  }
}
