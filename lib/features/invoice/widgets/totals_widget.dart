import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice.dart';

/// Invoice totals shown under the table.
class TotalsWidget extends StatelessWidget {
  const TotalsWidget({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: AppColors.textMuted, fontSize: 13);
    const valueStyle = TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Poids Brut: '
                  '${NumberFormatter.weight(invoice.totalGrossWeight)}',
                  style: labelStyle,
                ),
                Text(
                  'Total Eaux: '
                  '${NumberFormatter.weight(invoice.totalWaterWeight)}',
                  style: labelStyle,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Total Montant', style: labelStyle),
              Text(
                NumberFormatter.amount(invoice.totalAmount),
                style: valueStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
