import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/data/local/database/app_database.dart';
import 'package:gold_bar_invoice_management/data/remote/i_remote_sync_service.dart';
import 'package:gold_bar_invoice_management/data/repositories/invoice_repository_impl.dart';
import 'package:gold_bar_invoice_management/domain/services/gold_bar_calculator_service.dart';
import 'package:gold_bar_invoice_management/features/sync/services/sync_service.dart';
import 'package:gold_bar_invoice_management/features/sync/viewmodels/sync_viewmodel.dart';

class FakeRemote implements IRemoteSyncService {
  final pushed = <(String, String, Map<String, dynamic>)>[];
  bool failNext = false;
  List<Map<String, dynamic>> remoteInvoices = [];
  List<Map<String, dynamic>> remoteLines = [];

  @override
  Future<void> push({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    if (failNext) throw Exception('offline');
    pushed.add((table, operation, payload));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSavedInvoices() async =>
      remoteInvoices;

  @override
  Future<List<Map<String, dynamic>>> fetchInvoiceLines() async => remoteLines;
}

void main() {
  late AppDatabase db;
  late InvoiceRepositoryImpl repo;
  late FakeRemote remote;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InvoiceRepositoryImpl(db, GoldBarCalculatorService());
    remote = FakeRemote();
    sync = SyncService(db, remote, Connectivity());
  });

  tearDown(() async {
    sync.dispose();
    await db.close();
  });

  /// Creates, fills, finalizes and enqueues a 1-line invoice.
  Future<int> savedInvoice() async {
    final invoice = await repo.createDraft(
      issueDate: DateTime(2026, 6, 6),
      location: 'Bamako',
      basePrice: 70200,
    );
    await repo.addLine(
        invoiceId: invoice.id, grossWeight: 430.87, waterWeight: 23.67);
    await repo.finalizeInvoice(invoice.id);
    await repo.enqueueForSync(invoice.id);
    return invoice.id;
  }

  group('flushQueue', () {
    test('pushes in order, empties queue, stamps syncedAt locally',
        () async {
      final invoiceId = await savedInvoice();

      await sync.flushQueue();

      expect(remote.pushed.map((p) => p.$1), ['invoices', 'invoice_lines']);
      expect(await db.syncQueueDao.getPending(), isEmpty);

      final invoice = await repo.getInvoice(invoiceId);
      expect(invoice?.syncedAt, isNotNull);
      final lines = await repo.getLines(invoiceId);
      expect(lines.single.syncedAt, isNotNull);
    });

    test('failure increments attempts and stops the flush', () async {
      await savedInvoice();
      remote.failNext = true;

      await sync.flushQueue();

      expect(remote.pushed, isEmpty);
      final pending = await db.syncQueueDao.getPending();
      expect(pending, hasLength(2));
      expect(pending.first.attempts, 1); // only the first op was attempted
      expect(pending.last.attempts, 0);
    });

    test('3 failures abandon the op; retryFailed re-arms and pushes',
        () async {
      await savedInvoice();
      remote.failNext = true;

      for (var i = 0; i < 3; i++) {
        await sync.flushQueue();
      }
      expect(await sync.watchFailedCount().first, 1);

      remote.failNext = false;
      await sync.retryFailed();

      expect(await db.syncQueueDao.getPending(), isEmpty);
      expect(remote.pushed, hasLength(2));
    });
  });

  group('fullRestore', () {
    test('inserts remote invoices and lines locally, idempotent', () async {
      remote.remoteInvoices = [
        {
          'id': 1,
          'invoice_number': 'FAC-0001',
          'issue_date': '2026-06-06T00:00:00.000',
          'location': 'Bamako',
          'base_price': 70200,
          'status': 'saved',
          'bar_count': 1,
          'total_gross_weight': 430.87,
          'total_water_weight': 23.67,
          'total_amount': 30687031.02,
          'created_at': '2026-06-06T00:00:00.000',
          'updated_at': '2026-06-06T00:00:00.000',
        },
      ];
      remote.remoteLines = [
        {
          'id': 1,
          'invoice_id': 1,
          'bar_number': 1,
          'base_price': 70200,
          'gross_weight': 430.87,
          'water_weight': 23.67,
          'density': 18.20,
          'carat': 22.32,
          'unit_price': 71221.09,
          'amount': 30687031.02,
        },
      ];

      await sync.fullRestore();
      await sync.fullRestore(); // idempotent

      final invoice = await repo.getInvoice(1);
      expect(invoice?.invoiceNumber, 'FAC-0001');
      expect(invoice?.syncedAt, isNotNull);

      final lines = await repo.getLines(1);
      expect(lines.single.carat, 22.32);
    });
  });

  group('SyncViewModel', () {
    test('status: pending → synced after flush; error after 3 failures',
        () async {
      await savedInvoice();
      final vm = SyncViewModel(sync);
      await pumpEventQueue();
      expect(vm.status, SyncStatus.pending);
      expect(vm.pendingCount, 2);

      await sync.flushQueue();
      await pumpEventQueue();
      expect(vm.status, SyncStatus.synced);
      vm.dispose();
    });

    test('error status after abandoned ops', () async {
      await savedInvoice();
      remote.failNext = true;
      for (var i = 0; i < 3; i++) {
        await sync.flushQueue();
      }

      final vm = SyncViewModel(sync);
      await pumpEventQueue();
      expect(vm.status, SyncStatus.error);
      vm.dispose();
    });
  });
}
