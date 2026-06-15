import 'package:flutter/material.dart';

import '../features/invoice/views/invoice_entry_screen.dart';
import '../features/invoice/widgets/app_drawer.dart';
import '../features/invoice/widgets/backup_status_dot.dart';
import '../features/settings/widgets/theme_toggle_button.dart';

/// Root shell: AppBar + hamburger Drawer + InvoiceEntryScreen as body.
/// Replaces InvoiceListScreen as the app home.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Scaffold auto-adds the hamburger icon (and wires openDrawer)
        // whenever `drawer` is set — no explicit leading needed.
        title: const Text('Gestion Factures Or'),
        actions: const [ThemeToggleButton(), BackupStatusDot()],
      ),
      drawer: const AppDrawer(),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: const InvoiceEntryScreen(),
      ),
    );
  }
}
