import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../dao/invoice_dao.dart';
import '../dao/invoice_line_dao.dart';
import '../models/invoice_lines_table.dart';
import '../models/invoices_table.dart';

part 'app_database.g.dart';

/// Single source of truth for all app data (offline-first).
@DriftDatabase(
  tables: [Invoices, InvoiceLines],
  daos: [InvoiceDao, InvoiceLineDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests: `AppDatabase.forTesting(NativeDatabase.memory())`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Remove syncedAt columns. alterTable creates a new table with the
            // current schema, copies all matching columns, and drops the old one.
            await m.alterTable(TableMigration(invoices));
            await m.alterTable(TableMigration(invoiceLines));
            // Drop the sync_queue table entirely.
            await customStatement('DROP TABLE IF EXISTS sync_queue');
          }
        },
        beforeOpen: (details) async {
          // Required for the invoice_lines → invoices cascade delete.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() => driftDatabase(
        name: 'gold_bar_invoices',
        // Web (PWA): Drift runs SQLite via WebAssembly. These URIs resolve
        // against the page base href — the files ship in web/ (sqlite3.wasm,
        // drift_worker.js). Ignored on native (mobile/desktop).
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}
