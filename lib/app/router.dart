import 'package:go_router/go_router.dart';

import '../features/backup/views/backup_screen.dart';
import '../features/invoice/views/invoice_detail_screen.dart';
import '../features/invoice/views/invoice_history_screen.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, s) => const AppShell(),
    ),
    GoRoute(
      path: '/history',
      builder: (_, s) => const InvoiceHistoryScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) => InvoiceDetailScreen(
            invoiceId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/backup',
      builder: (_, s) => const BackupScreen(),
    ),
  ],
);
