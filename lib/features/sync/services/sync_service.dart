import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../data/local/database/app_database.dart';
import '../../../data/remote/i_remote_sync_service.dart';

/// Pushes the sync queue to the cloud whenever connectivity returns and
/// supports a full restore on a fresh install. Offline-first: the local
/// database stays the source of truth, this only mirrors it.
class SyncService {
  SyncService(this._db, this._remote, this._connectivity);

  final AppDatabase _db;
  final IRemoteSyncService _remote;
  final Connectivity _connectivity;

  /// True while a flush is running — observed by SyncViewModel.
  final ValueNotifier<bool> isSyncing = ValueNotifier(false);

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _flushing = false;

  /// Call once at app startup.
  void init() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) flushQueue();
    });
    // Also try right away in case the app starts online with a backlog.
    flushQueue();
  }

  Stream<int> watchPendingCount() => _db.syncQueueDao.watchPendingCount();

  Stream<int> watchFailedCount() => _db.syncQueueDao.watchFailedCount();

  /// Sends pending operations in queue order (invoices before their
  /// lines). Stops at the first failure: later operations may depend on
  /// the failed one, and a failure usually means we are offline anyway.
  Future<void> flushQueue() async {
    if (_flushing) return;
    _flushing = true;
    isSyncing.value = true;
    try {
      final pending = await _db.syncQueueDao.getPending();
      for (final op in pending) {
        try {
          await _remote.push(
            table: op.targetTable,
            operation: op.operation,
            payload: jsonDecode(op.payload) as Map<String, dynamic>,
          );
          await _db.syncQueueDao.markDone(op.id);
          await _markRecordSynced(op);
        } catch (_) {
          await _db.syncQueueDao.incrementAttempts(op.id);
          break;
        }
      }
    } finally {
      _flushing = false;
      isSyncing.value = false;
    }
  }

  /// Gives abandoned operations (3 failed attempts) another chance.
  Future<void> retryFailed() async {
    await _db.syncQueueDao.resetAttempts();
    await flushQueue();
  }

  /// Full restore from the cloud — new device or reinstall. Idempotent:
  /// existing rows are overwritten by id.
  Future<void> fullRestore() async {
    final invoices = await _remote.fetchSavedInvoices();
    final lines = await _remote.fetchInvoiceLines();
    final now = DateTime.now();

    await _db.transaction(() async {
      for (final json in invoices) {
        await _db
            .into(_db.invoices)
            .insertOnConflictUpdate(_invoiceFromJson(json, syncedAt: now));
      }
      for (final json in lines) {
        await _db
            .into(_db.invoiceLines)
            .insertOnConflictUpdate(_lineFromJson(json, syncedAt: now));
      }
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
    isSyncing.dispose();
  }

  Future<void> _markRecordSynced(SyncQueueRow op) async {
    final id = int.parse(op.recordId);
    final now = DateTime.now();
    switch (op.targetTable) {
      case 'invoices':
        await _db.invoiceDao
            .updateFields(id, InvoicesCompanion(syncedAt: Value(now)));
      case 'invoice_lines':
        await _db.invoiceLineDao.markSynced(id, now);
    }
  }

  InvoicesCompanion _invoiceFromJson(
    Map<String, dynamic> json, {
    required DateTime syncedAt,
  }) {
    return InvoicesCompanion(
      id: Value(json['id'] as int),
      invoiceNumber: Value(json['invoice_number'] as String),
      issueDate: Value(DateTime.parse(json['issue_date'] as String)),
      location: Value(json['location'] as String),
      basePrice: Value((json['base_price'] as num).toDouble()),
      status: Value(json['status'] as String),
      barCount: Value(json['bar_count'] as int),
      totalGrossWeight: Value((json['total_gross_weight'] as num).toDouble()),
      totalWaterWeight: Value((json['total_water_weight'] as num).toDouble()),
      totalAmount: Value((json['total_amount'] as num).toDouble()),
      createdAt: Value(DateTime.parse(json['created_at'] as String)),
      updatedAt: Value(DateTime.parse(json['updated_at'] as String)),
      syncedAt: Value(syncedAt),
    );
  }

  InvoiceLinesCompanion _lineFromJson(
    Map<String, dynamic> json, {
    required DateTime syncedAt,
  }) {
    return InvoiceLinesCompanion(
      id: Value(json['id'] as int),
      invoiceId: Value(json['invoice_id'] as int),
      barNumber: Value(json['bar_number'] as int),
      basePrice: Value((json['base_price'] as num).toDouble()),
      grossWeight: Value((json['gross_weight'] as num).toDouble()),
      waterWeight: Value((json['water_weight'] as num).toDouble()),
      density: Value((json['density'] as num).toDouble()),
      carat: Value((json['carat'] as num).toDouble()),
      unitPrice: Value((json['unit_price'] as num).toDouble()),
      amount: Value((json['amount'] as num).toDouble()),
      syncedAt: Value(syncedAt),
    );
  }
}
