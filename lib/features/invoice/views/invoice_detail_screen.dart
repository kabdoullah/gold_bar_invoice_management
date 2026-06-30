import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../viewmodels/invoice_history_viewmodel.dart';
import '../widgets/invoice_detail_panel.dart';

/// Editable view of a saved invoice — mobile only (on tablet the detail
/// shows in the master-detail pane of [InvoiceHistoryScreen]). Reached via
/// `push('/history/:id')`. AppBar Reprint regenerates the PDF straight from
/// the stored values; the body is the shared, editable [InvoiceDetailPanel]
/// (edit Poids/Eaux values only — no add/delete). Reprint is manual — the
/// operator taps it again after editing.
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
    final colors  = AppColors.of(context);
    final vm      = context.watch<InvoiceHistoryViewModel>();
    final invoice = vm.selectedInvoice;
    final lines   = vm.selectedLines;

    // Loading or stale (selection not yet for this route's id).
    if (invoice == null || invoice.id != widget.invoiceId) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          TextButton.icon(
            icon: vm.isReprinting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colors.appBarForeground),
                  )
                : Icon(Icons.print,
                    color: colors.appBarForeground, size: 18),
            label: Text('Réimprimer',
                style:
                    TextStyle(color: colors.appBarForeground, fontSize: 13)),
            onPressed: vm.isReprinting
                ? null
                : () async {
                    final ok = await vm.reprintInvoice(invoice, lines);
                    if (!ok && context.mounted) {
                      _showReprintError(context, colors, vm.reprintError);
                    }
                  },
          ),
        ],
      ),
      body: InvoiceDetailPanel(
        invoice: invoice,
        lines: lines,
        global: vm.globalCaratResult,
      ),
    );
  }

  void _showReprintError(
      BuildContext context, AppColorScheme colors, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colors.error,
        content: Text('Échec de l\'impression : ${message ?? 'erreur inconnue'}'),
      ),
    );
  }
}
