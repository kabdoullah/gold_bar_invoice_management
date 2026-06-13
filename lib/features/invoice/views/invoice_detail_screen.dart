import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../viewmodels/invoice_history_viewmodel.dart';
import '../widgets/invoice_detail_panel.dart';

/// Read-only view of a saved invoice — mobile only (on tablet the detail
/// shows in the master-detail pane of [InvoiceHistoryScreen]). Reached via
/// `push('/history/:id')`. AppBar Reprint regenerates the PDF straight from
/// the stored values; the body is the shared [InvoiceDetailPanel].
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
      body: InvoiceDetailPanel(invoice: invoice, lines: lines),
    );
  }
}
