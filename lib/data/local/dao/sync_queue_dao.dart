import 'package:drift/drift.dart';

import '../../../core/constants/business_constants.dart';
import '../database/app_database.dart';
import '../models/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

/// Data access for the `sync_queue` table.
@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<int> enqueue(SyncQueueCompanion entry) {
    return into(syncQueue).insert(entry);
  }

  /// Operations still eligible for a push attempt, oldest first so that
  /// invoices are created remotely before their lines.
  Future<List<SyncQueueRow>> getPending() {
    return (select(syncQueue)
          ..where(
              (q) => q.attempts.isSmallerThanValue(BusinessConstants.maxSyncAttempts))
          ..orderBy([(q) => OrderingTerm.asc(q.id)]))
        .get();
  }

  /// Count feeding the SyncStatusChip ("N pending").
  Stream<int> watchPendingCount() {
    final count = syncQueue.id.count();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(
          syncQueue.attempts.isSmallerThanValue(BusinessConstants.maxSyncAttempts));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Count of operations abandoned after too many failures ("Sync error").
  Stream<int> watchFailedCount() {
    final count = syncQueue.id.count();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.attempts
          .isBiggerOrEqualValue(BusinessConstants.maxSyncAttempts));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// A pushed operation is removed from the queue.
  Future<void> markDone(int id) async {
    await (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  Future<void> incrementAttempts(int id) async {
    await customUpdate(
      'UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {syncQueue},
    );
  }

  /// Gives abandoned operations another round of attempts
  /// (SyncStatusChip "retry" action).
  Future<void> resetAttempts() async {
    await customUpdate(
      'UPDATE sync_queue SET attempts = 0',
      updates: {syncQueue},
    );
  }
}
