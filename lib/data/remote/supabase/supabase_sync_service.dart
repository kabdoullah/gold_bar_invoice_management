import 'package:supabase_flutter/supabase_flutter.dart';

import '../i_remote_sync_service.dart';

/// Supabase implementation of the cloud backup. Every row carries the
/// static local [userId] (no real authentication in this version).
class SupabaseSyncService implements IRemoteSyncService {
  SupabaseSyncService(this._client, {required this.userId});

  final SupabaseClient _client;
  final String userId;

  @override
  Future<void> push({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    switch (operation) {
      case 'CREATE':
      case 'UPDATE':
        await _client.from(table).upsert({...payload, 'user_id': userId});
      case 'DELETE':
        await _client
            .from(table)
            .delete()
            .eq('id', payload['id'] as Object)
            .eq('user_id', userId);
      default:
        throw ArgumentError('Unknown sync operation: $operation');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSavedInvoices() async {
    final rows = await _client
        .from('invoices')
        .select()
        .eq('user_id', userId)
        .eq('status', 'saved');
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchInvoiceLines() async {
    final rows =
        await _client.from('invoice_lines').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(rows);
  }
}
