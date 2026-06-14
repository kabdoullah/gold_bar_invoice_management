import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

// Step 3 — full implementation (no missing deps, written here directly).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundTable,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                'Gestion Factures Or',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Divider(color: AppColors.tableBorder, height: 1),
            ListTile(
              leading: const Icon(Icons.description_outlined,
                  color: AppColors.textMuted),
              title: const Text('Historique des factures',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              onTap: () {
                Navigator.pop(context); // close the drawer
                context.push('/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined,
                  color: AppColors.textMuted),
              title: const Text('Sauvegarde & Restauration',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              onTap: () {
                Navigator.pop(context); // close the drawer
                context.push('/backup');
              },
            ),
          ],
        ),
      ),
    );
  }
}
