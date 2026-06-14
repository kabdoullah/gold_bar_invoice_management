import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/invoice.dart';
import '../viewmodels/invoice_history_viewmodel.dart';
import '../widgets/invoice_detail_panel.dart';

/// Read-only list of saved invoices, reached from the Drawer.
///
/// Mobile: simple list; tapping a row pushes `/history/:id`.
/// Tablet: master-detail side by side (280px list | flexible detail);
/// tapping a row loads the detail in-place, no navigation.
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
          : Responsive.isTablet(context)
              ? _buildTabletLayout(context, vm)
              : _buildList(context, vm, masterDetail: false),
    );
  }

  /// Tablet: list on the left, detail pane on the right.
  Widget _buildTabletLayout(BuildContext context, InvoiceHistoryViewModel vm) {
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: _buildList(context, vm, masterDetail: true),
        ),
        const VerticalDivider(width: 1, color: AppColors.tableBorder),
        Expanded(
          child: vm.selectedInvoice != null
              ? _DetailPane(vm: vm)
              : vm.isLoadingDetail
                  ? const Center(child: CircularProgressIndicator())
                  : const _EmptyDetail(),
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    InvoiceHistoryViewModel vm, {
    required bool masterDetail,
  }) {
    if (vm.savedInvoices.isEmpty) {
      return const Center(
        child: Text(
          'Aucune facture enregistrée.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.savedInvoices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final inv = vm.savedInvoices[i];
        return _HistoryRow(
          invoice: inv,
          selected: masterDetail && vm.selectedInvoice?.id == inv.id,
          onTap: masterDetail
              ? () => vm.selectInvoice(inv.id)
              : () => context.push('/history/${inv.id}'),
        );
      },
    );
  }
}

/// Tablet detail pane: reprint button row + read-only [InvoiceDetailPanel].
class _DetailPane extends StatelessWidget {
  const _DetailPane({required this.vm});

  final InvoiceHistoryViewModel vm;

  @override
  Widget build(BuildContext context) {
    final invoice = vm.selectedInvoice!;
    final lines   = vm.selectedLines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.invoiceNumber,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
                onPressed: vm.isReprinting
                    ? null
                    : () async {
                        final ok = await vm.reprintInvoice(invoice, lines);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.syncError,
                              content: Text(
                                'Échec de l\'impression : '
                                '${vm.reprintError ?? 'erreur inconnue'}',
                              ),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
        Expanded(
          child: InvoiceDetailPanel(invoice: invoice, lines: lines),
        ),
      ],
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Sélectionnez une facture.',
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.invoice,
    required this.onTap,
    this.selected = false,
  });

  final Invoice      invoice;
  final VoidCallback onTap;
  final bool         selected;

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
          border: Border.all(
            color: selected ? AppColors.tableHeader : AppColors.tableBorder,
            width: selected ? 1.5 : 0.5,
          ),
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
