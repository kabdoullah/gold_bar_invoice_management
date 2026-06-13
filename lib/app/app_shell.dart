import 'package:flutter/material.dart';

import '../features/invoice/views/invoice_entry_screen.dart';
import '../features/invoice/widgets/app_drawer.dart';
import '../features/invoice/widgets/backup_status_dot.dart';

/// Root shell: AppBar + hamburger Drawer + InvoiceEntryScreen as body.
/// Replaces InvoiceListScreen as the app home.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Factures Or'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: const [BackupStatusDot()],
      ),
      drawer: const AppDrawer(),
      body: const InvoiceEntryScreen(),
    );
  }
}
