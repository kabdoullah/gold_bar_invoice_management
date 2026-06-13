import 'package:go_router/go_router.dart';

import '../features/invoice/views/invoice_detail_screen.dart';
import '../features/invoice/views/invoice_form_screen.dart';
import '../features/invoice/views/invoice_list_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const InvoiceListScreen(),
    ),
    GoRoute(
      path: '/invoices/new',
      builder: (context, state) => const InvoiceFormScreen(),
    ),
    GoRoute(
      path: '/invoices/:id',
      builder: (context, state) => InvoiceDetailScreen(
        invoiceId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);
