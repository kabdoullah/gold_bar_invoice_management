/// Cloud backend contract for backup/restore. The app is offline-first:
/// this service is only ever called by SyncService, never by ViewModels.
abstract interface class IRemoteSyncService {
  /// Applies one queued operation remotely.
  ///
  /// [table] 'invoices' | 'invoice_lines'; [operation] CREATE | UPDATE |
  /// DELETE; [payload] the JSON snapshot from the sync queue.
  Future<void> push({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  });

  /// All remotely stored invoices (status = 'saved' only ever exists
  /// remotely), for full restore on a new device.
  Future<List<Map<String, dynamic>>> fetchSavedInvoices();

  Future<List<Map<String, dynamic>>> fetchInvoiceLines();
}
