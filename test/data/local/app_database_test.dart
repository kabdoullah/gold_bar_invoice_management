import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  InvoicesCompanion testInvoice(String number) => InvoicesCompanion.insert(
        invoiceNumber: number,
        issueDate: DateTime(2026, 6, 6),
        basePrice: 70200,
      );

  test('invoice insert applies schema defaults', () async {
    final id = await db.into(db.invoices).insert(testInvoice('FAC-001'));
    final row = await (db.select(db.invoices)
          ..where((i) => i.id.equals(id)))
        .getSingle();

    expect(row.location, "Côte d'Ivoire");
    expect(row.status, 'draft');
    expect(row.barCount, 0);
    expect(row.totalAmount, 0);
  });

  test('invoiceNumber is unique', () async {
    await db.into(db.invoices).insert(testInvoice('FAC-001'));
    expect(
      () => db.into(db.invoices).insert(testInvoice('FAC-001')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting an invoice cascades to its lines', () async {
    final invoiceId = await db.into(db.invoices).insert(testInvoice('FAC-001'));
    await db.into(db.invoiceLines).insert(InvoiceLinesCompanion.insert(
          invoiceId: invoiceId,
          barNumber: 1,
          basePrice: 70200,
          grossWeight: 430.87,
          waterWeight: 23.67,
          density: 18.20,
          carat: 22.32,
          unitPrice: 71221.09,
          amount: 30687031.02,
        ));

    await (db.delete(db.invoices)..where((i) => i.id.equals(invoiceId))).go();

    final lines = await db.select(db.invoiceLines).get();
    expect(lines, isEmpty);
  });
}
