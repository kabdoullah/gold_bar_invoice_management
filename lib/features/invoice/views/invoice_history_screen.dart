import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice.dart';
import '../viewmodels/invoice_history_viewmodel.dart';

/// Read-only list of saved invoices, reached from the Drawer. Tapping a
/// row opens the read-only detail at `/history/:id`.
class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceHistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Historique des factures'),
        backgroundColor: AppColors.tableHeader,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.savedInvoices.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune facture enregistrée.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.savedInvoices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final inv = vm.savedInvoices[i];
                    return _HistoryRow(
                      invoice: inv,
                      onTap: () => context.push('/history/${inv.id}'),
                    );
                  },
                ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.invoice, required this.onTap});

  final Invoice      invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bars = invoice.barCount;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundTable,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.tableBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormatter.date(invoice.issueDate)} · '
                    '$bars barre${bars > 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              NumberFormatter.amount(invoice.totalAmount),
              style: const TextStyle(
                color: AppColors.syncSuccess,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
