import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/sync_service.dart';

/// Aggregated sync state shown by the SyncStatusChip.
enum SyncStatus {
  /// Queue empty — everything is in the cloud.
  synced,

  /// Operations waiting for connectivity.
  pending,

  /// Flush in progress.
  syncing,

  /// At least one operation was abandoned after 3 failed attempts.
  error,
}

class SyncViewModel extends ChangeNotifier {
  SyncViewModel(this._syncService) {
    _pendingSub = _syncService.watchPendingCount().listen((count) {
      _pendingCount = count;
      notifyListeners();
    });
    _failedSub = _syncService.watchFailedCount().listen((count) {
      _failedCount = count;
      notifyListeners();
    });
    _syncService.isSyncing.addListener(notifyListeners);
  }

  final SyncService _syncService;

  late final StreamSubscription<int> _pendingSub;
  late final StreamSubscription<int> _failedSub;

  int _pendingCount = 0;
  int _failedCount = 0;

  int get pendingCount => _pendingCount;

  SyncStatus get status {
    if (_syncService.isSyncing.value) return SyncStatus.syncing;
    if (_failedCount > 0) return SyncStatus.error;
    if (_pendingCount > 0) return SyncStatus.pending;
    return SyncStatus.synced;
  }

  /// Manual retry from the chip: re-arms abandoned operations and
  /// flushes immediately.
  Future<void> retry() => _syncService.retryFailed();

  @override
  void dispose() {
    _pendingSub.cancel();
    _failedSub.cancel();
    _syncService.isSyncing.removeListener(notifyListeners);
    super.dispose();
  }
}
