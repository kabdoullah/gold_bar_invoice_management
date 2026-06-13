import 'package:drift/drift.dart';

/// Pending operations to push to Supabase once connectivity returns.
///
/// Only finalized invoices (status = 'saved') are ever enqueued.
@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Remote table to write to: 'invoices' | 'invoice_lines'.
  ///
  /// Named `targetTable` in Dart because drift's `Table` already defines
  /// a `tableName` member; the SQL column stays `table_name`.
  TextColumn get targetTable => text().named('table_name')();

  /// CREATE | UPDATE | DELETE.
  TextColumn get operation => text()();

  /// Local record id, as text for forward compatibility.
  TextColumn get recordId => text()();

  /// JSON snapshot of the record at enqueue time.
  TextColumn get payload => text()();

  /// Failed push attempts — abandoned after BusinessConstants.maxSyncAttempts.
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
