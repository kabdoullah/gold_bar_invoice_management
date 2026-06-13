import 'package:drift/drift.dart' as drift;
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

  Future<int> insertInvoice({String number = 'FAC-001', String? status}) {
    return db.invoiceDao.insertInvoice(InvoicesCompanion.insert(
      invoiceNumber: number,
      issueDate: DateTime(2026, 6, 6),
      basePrice: 70200,
      status: status == null
          ? const drift.Value.absent()
          : drift.Value(status),
    ));
  }

  Future<int> insertLine(int invoiceId, int barNumber,
      {double gross = 430.87, double water = 23.67, double amount = 30687031.02}) {
    return db.invoiceLineDao.insertLine(InvoiceLinesCompanion.insert(
      invoiceId: invoiceId,
      barNumber: barNumber,
      basePrice: 70200,
      grossWeight: gross,
      waterWeight: water,
      density: 18.20,
      carat: 22.32,
      unitPrice: 71221.09,
      amount: amount,
    ));
  }

  group('InvoiceDao', () {
    test('findDraft returns the draft, watchSaved only saved invoices',
        () async {
      await insertInvoice(number: 'FAC-001', status: 'saved');
      final draftId = await insertInvoice(number: 'FAC-002');

      final draft = await db.invoiceDao.findDraft();
      expect(draft?.id, draftId);

      final saved = await db.invoiceDao.watchSaved().first;
      expect(saved.map((i) => i.invoiceNumber), ['FAC-001']);
    });

    test('maxId is 0 on empty table, then highest id', () async {
      expect(await db.invoiceDao.maxId(), 0);
      await insertInvoice(number: 'FAC-001');
      final id2 = await insertInvoice(number: 'FAC-002');
      expect(await db.invoiceDao.maxId(), id2);
    });

    test('updateFields changes status', () async {
      final id = await insertInvoice();
      await db.invoiceDao.updateFields(
        id,
        const InvoicesCompanion(status: drift.Value('saved')),
      );
      final row = await db.invoiceDao.getById(id);
      expect(row?.status, 'saved');
    });
  });

  group('InvoiceLineDao', () {
    test('nextBarNumber starts at 1 and increments', () async {
      final invoiceId = await insertInvoice();
      expect(await db.invoiceLineDao.nextBarNumber(invoiceId), 1);
      await insertLine(invoiceId, 1);
      await insertLine(invoiceId, 2);
      expect(await db.invoiceLineDao.nextBarNumber(invoiceId), 3);
    });

    test('totalsForInvoice aggregates count and sums', () async {
      final invoiceId = await insertInvoice();
      await insertLine(invoiceId, 1, gross: 430.87, water: 23.67, amount: 100);
      await insertLine(invoiceId, 2, gross: 126.39, water: 6.87, amount: 50);

      final totals = await db.invoiceLineDao.totalsForInvoice(invoiceId);
      expect(totals.barCount, 2);
      expect(totals.totalGrossWeight, closeTo(557.26, 0.001));
      expect(totals.totalWaterWeight, closeTo(30.54, 0.001));
      expect(totals.totalAmount, closeTo(150, 0.001));
    });

    test('getForInvoice returns lines in bar order', () async {
      final invoiceId = await insertInvoice();
      await insertLine(invoiceId, 2);
      await insertLine(invoiceId, 1);
      final lines = await db.invoiceLineDao.getForInvoice(invoiceId);
      expect(lines.map((l) => l.barNumber), [1, 2]);
    });
  });
}
