import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/database/app_database.dart';
import '../data/remote/i_remote_sync_service.dart';
import '../data/remote/supabase/supabase_sync_service.dart';
import '../data/repositories/invoice_repository_impl.dart';
import '../domain/repositories/i_invoice_repository.dart';
import '../domain/services/gold_bar_calculator_service.dart';
import '../domain/services/print_service.dart';
import '../features/sync/services/sync_service.dart';
import '../features/sync/viewmodels/sync_viewmodel.dart';

/// Compile-time configuration:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// Without credentials the app runs fully offline: operations accumulate
/// in the sync queue (amber chip) until a configured build pushes them.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Static local user id — no real authentication in this version.
  static const syncUserId =
      String.fromEnvironment('SYNC_USER_ID', defaultValue: 'operator-1');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

/// Placeholder remote when Supabase is not configured: every push fails,
/// so operations stay queued locally and nothing is lost.
class _UnconfiguredRemote implements IRemoteSyncService {
  @override
  Future<void> push({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    throw StateError('Supabase is not configured');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSavedInvoices() async => const [];

  @override
  Future<List<Map<String, dynamic>>> fetchInvoiceLines() async => const [];
}

/// Root Provider tree — order matters: each entry may read the ones
/// declared above it.
List<SingleChildWidget> buildProviders() {
  return [
    Provider<AppDatabase>(
      create: (_) => AppDatabase(),
      dispose: (_, db) => db.close(),
    ),
    Provider<GoldBarCalculatorService>(
      create: (_) => GoldBarCalculatorService(),
    ),
    Provider<PrintService>(create: (_) => PrintService()),
    Provider<IInvoiceRepository>(
      create: (context) => InvoiceRepositoryImpl(
        context.read<AppDatabase>(),
        context.read<GoldBarCalculatorService>(),
      ),
    ),
    Provider<IRemoteSyncService>(
      create: (_) => AppConfig.isSupabaseConfigured
          ? SupabaseSyncService(
              Supabase.instance.client,
              userId: AppConfig.syncUserId,
            )
          : _UnconfiguredRemote(),
    ),
    Provider<SyncService>(
      lazy: false,
      create: (context) {
        final service = SyncService(
          context.read<AppDatabase>(),
          context.read<IRemoteSyncService>(),
          Connectivity(),
        );
        // No auto-flush without a backend — the queue would only burn
        // its 3 attempts and show a misleading error chip.
        if (AppConfig.isSupabaseConfigured) {
          service.init();
        }
        return service;
      },
      dispose: (_, service) => service.dispose(),
    ),
    ChangeNotifierProvider<SyncViewModel>(
      create: (context) => SyncViewModel(context.read<SyncService>()),
    ),
  ];
}
