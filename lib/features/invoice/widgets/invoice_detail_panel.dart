import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_line.dart';
import '../../../domain/services/gold_bar_calculator_service.dart';
import 'invoice_table.dart';
import 'totals_widget.dart';

/// Read-only body for a saved invoice: header (location/date + bar count),
/// dense line table, totals. No Scaffold, no reprint control — the host
/// supplies those (AppBar action on mobile, button on tablet).
///
/// Shared by the mobile [InvoiceDetailScreen] and the tablet master-detail
/// pane in [InvoiceHistoryScreen]. Table scroll follows [Responsive].
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
          InvoiceTable(
            lines: lines,
            scrollable: !Responsive.isTablet(context),
          ),
          const SizedBox(height: 8),
          TotalsWidget(invoice: invoice, global: global),
        ],
      ),
    );
  }
}
