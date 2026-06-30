import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_line.dart';
import '../../../domain/services/gold_bar_calculator_service.dart';
import '../viewmodels/invoice_history_viewmodel.dart';
import 'editable_invoice_table.dart';
import 'totals_widget.dart';

/// Editable body for a saved invoice: header (location/date + bar count),
/// read-only base price, the dense line table with **inline-editable**
/// Poids/Eaux, and the totals row. No Scaffold, no reprint control — the host
/// supplies those (AppBar action on mobile, button on tablet).
///
/// Shared by the mobile [InvoiceDetailScreen] and the tablet master-detail
/// pane in [InvoiceHistoryScreen]; both therefore edit identically. Editing
/// is **values only** — lines are never added or removed, so the bar count is
/// fixed. basePrice and invoiceNumber never change.
///
/// Display data comes from the props (the host passes the VM's current
/// selection, which it watches); edits go through the
/// [InvoiceHistoryViewModel] read from the Provider tree. Table scroll
/// follows [Responsive].
class InvoiceDetailPanel extends StatelessWidget {
  const InvoiceDetailPanel({
    super.key,
    required this.invoice,
    required this.lines,
    required this.global,
  });

  final Invoice           invoice;
  final List<InvoiceLine> lines;
  final GlobalCaratResult global;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final vm     = context.watch<InvoiceHistoryViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${BusinessConstants.defaultLocation} le: '
                '${NumberFormatter.date(invoice.issueDate)}',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              Text(
                'Nombre Barres: ${invoice.barCount}',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BasePriceDisplay(basePrice: invoice.basePrice),
          const SizedBox(height: 12),
          EditableInvoiceTable(
            lines: lines,
            enabled: !vm.isMutating,
            scrollable: !Responsive.isTablet(context),
            onCommit: (line, gross, water) =>
                vm.updateLineInSelectedInvoice(line.id, gross, water),
          ),
          const SizedBox(height: 8),
          TotalsWidget(invoice: invoice, global: global),
        ],
      ),
    );
  }
}

/// Read-only base price row — displayed (the operator needs to see the locked
/// rate) but never editable on an existing invoice.
class _BasePriceDisplay extends StatelessWidget {
  const _BasePriceDisplay({required this.basePrice});

  final double basePrice;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Prix de base',
              style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          Text(
            NumberFormatter.amount(basePrice),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
