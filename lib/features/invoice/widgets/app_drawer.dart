import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                'Gestion Factures Or',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Divider(color: colors.border, height: 1),
            ListTile(
              leading: Icon(Icons.description_outlined,
                  color: colors.textSecondary),
              title: Text('Historique des factures',
                  style: TextStyle(color: colors.textPrimary, fontSize: 14)),
              onTap: () {
                Navigator.pop(context); // close the drawer
                context.push('/history');
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud_upload_outlined,
                  color: colors.textSecondary),
              title: Text('Sauvegarde & Restauration',
                  style: TextStyle(color: colors.textPrimary, fontSize: 14)),
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
