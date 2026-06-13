import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/entities/invoice_line.dart';

/// "Récapitulatif" card shown under the table: the four column totals in an
/// equal-width grid (4-in-a-row on tablet, 2×2 on mobile) plus the grand
/// total amount emphasized below a divider. Carat total always red.
class TotalsWidget extends StatelessWidget {
  const TotalsWidget({super.key, required this.invoice, required this.lines});

  final Invoice           invoice;
  final List<InvoiceLine> lines;

  @override
  Widget build(BuildContext context) {
    final stats = <Widget>[
      _Stat('Poids Total', NumberFormatter.weight(invoice.totalGrossWeight)),
      _Stat('Eaux Total', NumberFormatter.weight(invoice.totalWaterWeight)),
      _Stat('Densité Total', NumberFormatter.density(lines.totalDensity)),
      _Stat('Carat Total', NumberFormatter.carat(lines.totalCarat), isRed: true),
    ];

    final grid = Responsive.isTablet(context)
        ? Row(children: [for (final s in stats) Expanded(child: s)])
        : Column(
            children: [
              Row(children: [Expanded(child: stats[0]), Expanded(child: stats[1])]),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: stats[2]), Expanded(child: stats[3])]),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundTable,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tableBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          grid,
          const Divider(color: AppColors.tableBorder, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Montant Total',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              Text(
                NumberFormatter.amount(invoice.totalAmount),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One labelled total: muted label above, bold value below.
class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.isRed = false});

  final String label;
  final String value;
  final bool   isRed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isRed ? AppColors.accentCarat : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
