import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../viewmodels/invoice_history_viewmodel.dart';
import '../widgets/invoice_table.dart';
import '../widgets/totals_widget.dart';

/// Read-only view of a saved invoice, reached from [InvoiceHistoryScreen].
/// Header + dense line table + totals + Reprint. No editing, no deletion —
/// reprint regenerates the PDF straight from the stored values.
///
/// Stateful only to fire [InvoiceHistoryViewModel.selectInvoice] once on
/// open; the shared history VM holds the loaded invoice + lines.
class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  final int invoiceId;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceHistoryViewModel>().selectInvoice(widget.invoiceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<InvoiceHistoryViewModel>();
    final invoice = vm.selectedInvoice;
    final lines   = vm.selectedLines;

    // Loading or stale (selection not yet for this route's id).
    if (invoice == null || invoice.id != widget.invoiceId) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(backgroundColor: AppColors.tableHeader),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.tableHeader,
        title: Text(invoice.invoiceNumber),
        actions: [
          TextButton.icon(
            icon: vm.isReprinting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.textPrimary),
                  )
                : const Icon(Icons.print,
                    color: AppColors.textPrimary, size: 18),
            label: const Text('Réimprimer',
                style:
                    TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            onPressed: vm.isReprinting
                ? null
                : () => vm.reprintInvoice(invoice, lines),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${invoice.location} le: '
                  '${NumberFormatter.date(invoice.issueDate)}',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                ),
                Text(
                  'Nombre Barres: ${invoice.barCount}',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InvoiceTable(lines: lines),
            const SizedBox(height: 8),
            TotalsWidget(invoice: invoice, lines: lines),
          ],
        ),
      ),
    );
  }
}
