import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/services/gold_bar_calculator_service.dart';

/// "Récapitulatif" card shown under the table: the four column totals in an
/// equal-width grid (4-in-a-row on tablet, 2×2 on mobile) plus the grand
/// total amount emphasized below a divider. Carat Général always red.
///
/// "Densité Totale" / "Carat Général" come from [global], recomputed by the
/// viewmodel from the invoice's raw totals — never a sum of per-line values.
class TotalsWidget extends StatelessWidget {
  const TotalsWidget({super.key, required this.invoice, required this.global});

  final Invoice           invoice;
  final GlobalCaratResult global;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final stats = <Widget>[
      _Stat('Poids Total', NumberFormatter.weight(invoice.totalGrossWeight)),
      _Stat('Eaux Total', NumberFormatter.weight(invoice.totalWaterWeight)),
      _Stat('Densité Totale', NumberFormatter.density(global.globalDensity)),
      _Stat('Carat Général', NumberFormatter.carat(global.globalCarat),
          isRed: true),
    ];

    final grid = Responsive.isTablet(context)
        ? Row(children: [for (final s in stats) Expanded(child: s)])
        : Column(
            children: [
              Row(children: [Expanded(child: stats[0]), Expanded(child: stats[1])]),
              const SizedBox(height: 6),
              Row(children: [Expanded(child: stats[2]), Expanded(child: stats[3])]),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        color: colors.totalBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          grid,
          Divider(color: colors.border, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Montant Total',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              Text(
                NumberFormatter.amount(invoice.totalAmount),
                style: TextStyle(
                  color: colors.totalText,
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
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isRed ? colors.accentCarat : colors.totalText,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
