import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../dao/invoice_dao.dart';
import '../dao/invoice_line_dao.dart';
import '../dao/sync_queue_dao.dart';
import '../models/invoice_lines_table.dart';
import '../models/invoices_table.dart';
import '../models/sync_queue_table.dart';

part 'app_database.g.dart';

/// Single source of truth for all app data (offline-first).
@DriftDatabase(
  tables: [Invoices, InvoiceLines, SyncQueue],
  daos: [InvoiceDao, InvoiceLineDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests: `AppDatabase.forTesting(NativeDatabase.memory())`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          // Required for the invoice_lines → invoices cascade delete.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'gold_bar_invoices');
}
