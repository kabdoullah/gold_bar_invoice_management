import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/core/errors/business_exceptions.dart';
import 'package:gold_bar_invoice_management/data/local/database/app_database.dart';
import 'package:gold_bar_invoice_management/data/repositories/invoice_repository_impl.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice_status.dart';
import 'package:gold_bar_invoice_management/domain/services/gold_bar_calculator_service.dart';

void main() {
  late AppDatabase db;
  late InvoiceRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InvoiceRepositoryImpl(db, GoldBarCalculatorService());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> createDraft({double basePrice = 70200}) async {
    final invoice = await repo.createDraft(
      issueDate: DateTime(2026, 6, 6),
      location: 'Bamako',
      basePrice: basePrice,
    );
    return invoice.id;
  }

  group('createDraft', () {
    test('persists immediately with status draft and a sequential number',
        () async {
      final id = await createDraft();
      final invoice = await repo.getInvoice(id);
      expect(invoice?.status, InvoiceStatus.draft);
      expect(invoice?.invoiceNumber, 'FAC-0001');
      expect(invoice?.barCount, 0);
    });

    test('refuses a second draft', () async {
      await createDraft();
      expect(createDraft(), throwsA(isA<InvoiceStateException>()));
    });
  });

  group('addLine', () {
    test('stores calculated values and refreshes totals (capture line 1)',
        () async {
      final id = await createDraft();
      final line = await repo.addLine(
        invoiceId: id,
        grossWeight: 430.87,
        waterWeight: 23.67,
      );

      expect(line.barNumber, 1);
      expect(line.density, 18.20);
      // carat stored at float32 precision (22.32 → 22.31999969…), displays
      // as 22.32 after rounding — see GoldBarCalculatorService.
      expect(line.carat, closeTo(22.32, 0.001));
      expect(line.unitPrice, closeTo(71221.09, 0.01));
      expect(line.amount, 30687031.02); // exact desktop match

      final invoice = await repo.getInvoice(id);
      expect(invoice?.barCount, 1);
      expect(invoice?.totalGrossWeight, closeTo(430.87, 0.001));
      expect(invoice?.totalWaterWeight, closeTo(23.67, 0.001));
      expect(invoice?.totalAmount, 30687031.02); // exact desktop match
    });

    test('full capture invoice: 5 lines reach the expected totals', () async {
      final id = await createDraft();
      const bars = [
        (430.87, 23.67),
        (126.39, 6.87),
        (73.18, 3.98),
        (37.69, 2.06),
        (30.22, 1.63),
      ];
      for (final (gross, water) in bars) {
        await repo.addLine(invoiceId: id, grossWeight: gross, waterWeight: water);
      }

      final invoice = await repo.getInvoice(id);
      expect(invoice?.barCount, 5);
      expect(invoice?.totalGrossWeight, closeTo(698.35, 0.001));
      expect(invoice?.totalWaterWeight, closeTo(38.21, 0.001));
      expect(invoice?.totalAmount, closeTo(50006468.85, 0.001)); // exact desktop total
    });

    test('rejects lines on a saved invoice', () async {
      final id = await createDraft();
      await repo.addLine(invoiceId: id, grossWeight: 430.87, waterWeight: 23.67);
      await repo.finalizeInvoice(id);

      expect(
        repo.addLine(invoiceId: id, grossWeight: 126.39, waterWeight: 6.87),
        throwsA(isA<InvoiceStateException>()),
      );
    });
  });

  group('deleteLine', () {
    test('refreshes totals', () async {
      final id = await createDraft();
      final line1 = await repo.addLine(
          invoiceId: id, grossWeight: 430.87, waterWeight: 23.67);
      await repo.addLine(invoiceId: id, grossWeight: 126.39, waterWeight: 6.87);

      await repo.deleteLine(lineId: line1.id, invoiceId: id);

      final invoice = await repo.getInvoice(id);
      expect(invoice?.barCount, 1);
      expect(invoice?.totalGrossWeight, closeTo(126.39, 0.001));
    });
  });

  group('updateDraftHeader', () {
    test('rejects basePrice change once lines exist', () async {
      final id = await createDraft();
      await repo.addLine(invoiceId: id, grossWeight: 430.87, waterWeight: 23.67);
      expect(
        repo.updateDraftHeader(id, basePrice: 71000),
        throwsA(isA<InvoiceStateException>()),
      );
    });

    test('updates location and issueDate on a draft', () async {
      final id = await createDraft();
      await repo.updateDraftHeader(id,
          location: 'Kayes', issueDate: DateTime(2026, 6, 7));
      final invoice = await repo.getInvoice(id);
      expect(invoice?.location, 'Kayes');
      expect(invoice?.issueDate, DateTime(2026, 6, 7));
    });
  });

  group('finalize + enqueue', () {
    test('finalizeInvoice flips status; empty draft is refused', () async {
      final emptyId = await createDraft();
      expect(repo.finalizeInvoice(emptyId),
          throwsA(isA<InvoiceStateException>()));

      await repo.addLine(
          invoiceId: emptyId, grossWeight: 430.87, waterWeight: 23.67);
      await repo.finalizeInvoice(emptyId);
      final invoice = await repo.getInvoice(emptyId);
      expect(invoice?.status, InvoiceStatus.saved);
    });

  });

  group('discardDraft', () {
    test('removes the draft and its lines', () async {
      final id = await createDraft();
      await repo.addLine(invoiceId: id, grossWeight: 430.87, waterWeight: 23.67);

      await repo.discardDraft(id);

      expect(await repo.getInvoice(id), isNull);
      expect(await db.invoiceLineDao.getForInvoice(id), isEmpty);
      expect(await repo.findDraft(), isNull);
    });

    test('refuses to discard a saved invoice', () async {
      final id = await createDraft();
      await repo.addLine(invoiceId: id, grossWeight: 430.87, waterWeight: 23.67);
      await repo.finalizeInvoice(id);
      expect(repo.discardDraft(id), throwsA(isA<InvoiceStateException>()));
    });
  });
}
