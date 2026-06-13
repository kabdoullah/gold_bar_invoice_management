import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/data/local/database/app_database.dart';
import 'package:gold_bar_invoice_management/data/repositories/invoice_repository_impl.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice_line.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice_status.dart';
import 'package:gold_bar_invoice_management/domain/services/gold_bar_calculator_service.dart';
import 'package:gold_bar_invoice_management/domain/services/print_service.dart';
import 'package:gold_bar_invoice_management/features/invoice/viewmodels/invoice_detail_viewmodel.dart';
import 'package:gold_bar_invoice_management/features/invoice/viewmodels/invoice_list_viewmodel.dart';

/// Records calls instead of opening the native print sheet.
class FakePrintService extends PrintService {
  int printCalls = 0;
  Invoice? lastInvoice;
  List<InvoiceLine>? lastLines;

  @override
  Future<void> printInvoice(Invoice invoice, List<InvoiceLine> lines) async {
    printCalls++;
    lastInvoice = invoice;
    lastLines = lines;
  }
}

void main() {
  late AppDatabase db;
  late InvoiceRepositoryImpl repo;
  late FakePrintService printService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InvoiceRepositoryImpl(db, GoldBarCalculatorService());
    printService = FakePrintService();
  });

  tearDown(() async {
    await db.close();
  });

  Future<Invoice> createDraft() => repo
      .createDraft(
        issueDate: DateTime(2026, 6, 6),
        location: 'Bamako',
        basePrice: 70200,
      );

  InvoiceDetailViewModel detailVm(int invoiceId) => InvoiceDetailViewModel(
        repo,
        GoldBarCalculatorService(),
        printService,
        invoiceId: invoiceId,
      );

  group('InvoiceListViewModel', () {
    test('exposes saved invoices and the draft', () async {
      final draft = await createDraft();
      await repo.addLine(
          invoiceId: draft.id, grossWeight: 430.87, waterWeight: 23.67);

      final vm = InvoiceListViewModel(repo);
      await pumpEventQueue();

      expect(vm.isLoading, false);
      expect(vm.invoices, isEmpty); // draft is not listed
      expect(vm.draft?.id, draft.id);

      vm.dispose();
    });

    test('createDraft returns the new invoice; second draft sets error',
        () async {
      final vm = InvoiceListViewModel(repo);
      await pumpEventQueue();

      final invoice = await vm.createDraft(
        issueDate: DateTime(2026, 6, 6),
        location: 'Bamako',
        basePrice: 70200,
      );
      expect(invoice?.invoiceNumber, 'FAC-0001');

      final second = await vm.createDraft(
        issueDate: DateTime(2026, 6, 6),
        location: 'Bamako',
        basePrice: 70200,
      );
      expect(second, isNull);
      expect(vm.error, isNotNull);

      vm.dispose();
    });

    test('discardDraft removes the draft', () async {
      await createDraft();
      final vm = InvoiceListViewModel(repo);
      await pumpEventQueue();
      expect(vm.draft, isNotNull);

      await vm.discardDraft();
      await pumpEventQueue();
      expect(vm.draft, isNull);

      vm.dispose();
    });
  });

  group('InvoiceDetailViewModel', () {
    test('loads invoice and lines via streams', () async {
      final draft = await createDraft();
      await repo.addLine(
          invoiceId: draft.id, grossWeight: 430.87, waterWeight: 23.67);

      final vm = detailVm(draft.id);
      await pumpEventQueue();

      expect(vm.isLoading, false);
      expect(vm.invoice?.id, draft.id);
      expect(vm.lines, hasLength(1));
      expect(vm.lines.first.carat, 22.32);

      vm.dispose();
    });

    test('previewLine returns calculated values, null on invalid input',
        () async {
      final draft = await createDraft();
      final vm = detailVm(draft.id);
      await pumpEventQueue();

      final preview = vm.previewLine(430.87, 23.67);
      expect(preview?.density, 18.20);
      expect(preview?.carat, 22.32);
      expect(preview?.amount, closeTo(30687031.02, 0.5));

      expect(vm.previewLine(430.87, 0), isNull);
      expect(vm.previewLine(0, 23.67), isNull);

      vm.dispose();
    });

    test('addLine persists and streams push updated totals', () async {
      final draft = await createDraft();
      final vm = detailVm(draft.id);
      await pumpEventQueue();

      expect(vm.canSaveAndPrint, false); // no lines yet

      final ok = await vm.addLine(430.87, 23.67);
      expect(ok, true);
      await pumpEventQueue();

      expect(vm.lines, hasLength(1));
      expect(vm.invoice?.barCount, 1);
      expect(vm.invoice?.totalAmount, closeTo(30687031.02, 0.5));
      expect(vm.canSaveAndPrint, true);

      vm.dispose();
    });

    test('deleteLine refreshes state', () async {
      final draft = await createDraft();
      final line = await repo.addLine(
          invoiceId: draft.id, grossWeight: 430.87, waterWeight: 23.67);

      final vm = detailVm(draft.id);
      await pumpEventQueue();

      await vm.deleteLine(line.id);
      await pumpEventQueue();

      expect(vm.lines, isEmpty);
      expect(vm.invoice?.barCount, 0);

      vm.dispose();
    });

    test('saveAndPrint finalizes, enqueues and prints', () async {
      final draft = await createDraft();
      await repo.addLine(
          invoiceId: draft.id, grossWeight: 430.87, waterWeight: 23.67);

      final vm = detailVm(draft.id);
      await pumpEventQueue();

      final ok = await vm.saveAndPrint();
      expect(ok, true);
      await pumpEventQueue();

      expect(vm.invoice?.status, InvoiceStatus.saved);
      expect(printService.printCalls, 1);
      expect(printService.lastInvoice?.status, InvoiceStatus.saved);
      expect(printService.lastLines, hasLength(1));

      final pending = await db.syncQueueDao.getPending();
      expect(pending, hasLength(2)); // invoice + 1 line
      expect(vm.canSaveAndPrint, false); // already saved

      vm.dispose();
    });

    test('saveAndPrint on an empty draft sets error, does not print',
        () async {
      final draft = await createDraft();
      final vm = detailVm(draft.id);
      await pumpEventQueue();

      final ok = await vm.saveAndPrint();
      expect(ok, false);
      expect(vm.error, isNotNull);
      expect(printService.printCalls, 0);

      vm.dispose();
    });
  });
}
