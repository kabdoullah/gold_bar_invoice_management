import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/local/database/app_database.dart';
import '../data/remote/google_drive/google_drive_service.dart';
import '../data/repositories/invoice_repository_impl.dart';
import '../data/services/export_service.dart';
import '../data/services/import_service.dart';
import '../domain/repositories/i_invoice_repository.dart';
import '../domain/services/backup_service.dart';
import '../domain/services/gold_bar_calculator_service.dart';
import '../domain/services/print_service.dart';
import '../features/backup/viewmodels/backup_view_model.dart';
import '../features/invoice/viewmodels/invoice_entry_viewmodel.dart';
import '../features/invoice/viewmodels/invoice_history_viewmodel.dart';
import '../features/settings/viewmodels/theme_view_model.dart';

/// Root Provider tree — order matters: each entry may read the ones
/// declared above it.
List<SingleChildWidget> buildProviders() {
  return [
    // Theme mode (light/dark/system) + persistence — read by GoldBarApp.
    ChangeNotifierProvider<ThemeViewModel>(
      create: (_) => ThemeViewModel()..init(),
    ),
    Provider<AppDatabase>(
      create: (_) => AppDatabase(),
      dispose: (_, db) => db.close(),
    ),
    Provider<GoldBarCalculatorService>(
      create: (_) => GoldBarCalculatorService(),
    ),
    Provider<PrintService>(
      create: (_) => PrintService(),
    ),
    Provider<IInvoiceRepository>(
      create: (ctx) => InvoiceRepositoryImpl(
        ctx.read<AppDatabase>(),
        ctx.read<GoldBarCalculatorService>(),
      ),
    ),
    Provider<ExportService>(
      create: (ctx) {
        final db = ctx.read<AppDatabase>();
        return ExportService(db.invoiceDao, db.invoiceLineDao, db.schemaVersion);
      },
    ),
    Provider<ImportService>(
      create: (ctx) => ImportService(ctx.read<AppDatabase>()),
    ),
    Provider<GoogleDriveService>(
      create: (_) => GoogleDriveService(),
    ),
    Provider<BackupService>(
      create: (ctx) => BackupService(
        ctx.read<ExportService>(),
        ctx.read<GoogleDriveService>(),
      ),
    ),
    ChangeNotifierProvider<BackupViewModel>(
      create: (ctx) => BackupViewModel(
        backupService: ctx.read<BackupService>(),
        importService: ctx.read<ImportService>(),
        driveService:  ctx.read<GoogleDriveService>(),
      )..init(),
    ),
    // Global: shared by the AppBar BackupStatusDot and the entry screen
    // body — single-user app, one live draft at a time.
    ChangeNotifierProvider<InvoiceEntryViewModel>(
      create: (ctx) => InvoiceEntryViewModel(
        ctx.read<IInvoiceRepository>(),
        ctx.read<GoldBarCalculatorService>(),
        ctx.read<PrintService>(),
        ctx.read<BackupService>(),
      ),
    ),
    // Global: shared across the /history list and /history/:id detail so
    // the loaded selection survives navigation.
    ChangeNotifierProvider<InvoiceHistoryViewModel>(
      create: (ctx) => InvoiceHistoryViewModel(
        ctx.read<IInvoiceRepository>(),
        ctx.read<PrintService>(),
      ),
    ),
  ];
}
