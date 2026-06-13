import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/invoice_line.dart';

/// Dense tabular display of invoice lines, faithful to the original
/// desktop software. Tablet: full width. Mobile: horizontal scroll.
///
/// Carat column always red; Base column dimmed (shared fixed value).
class InvoiceTable extends StatelessWidget {
  const InvoiceTable({
    super.key,
    required this.lines,
    this.onDeleteLine,
  });

  final List<InvoiceLine> lines;

  /// Non-null while the invoice is a draft — shows a delete icon per row.
  final void Function(InvoiceLine line)? onDeleteLine;

  static const _headerLabels = [
    'Base',
    'Poids Brut',
    'Eaux',
    'Densité',
    'CARAT',
    'U/BASE',
    'Montant',
  ];

  bool get _canDelete => onDeleteLine != null;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return _buildTable(flexible: true);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildTable(flexible: false),
    );
  }

  Widget _buildTable({required bool flexible}) {
    const fixedWidths = [100.0, 90.0, 80.0, 80.0, 80.0, 110.0, 140.0];
    return Table(
      border: TableBorder.all(color: AppColors.tableBorder, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        for (var i = 0; i < fixedWidths.length; i++)
          i: flexible
              ? const FlexColumnWidth()
              : FixedColumnWidth(fixedWidths[i]),
        if (_canDelete) fixedWidths.length: const FixedColumnWidth(44),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.tableHeader),
          children: [
            for (final label in _headerLabels) _headerCell(label),
            if (_canDelete) const SizedBox.shrink(),
          ],
        ),
        for (final line in lines)
          TableRow(
            decoration: const BoxDecoration(color: AppColors.backgroundTable),
            children: [
              _cell(NumberFormatter.amount(line.basePrice),
                  color: AppColors.textMuted),
              _cell(NumberFormatter.weight(line.grossWeight)),
              _cell(NumberFormatter.weight(line.waterWeight)),
              _cell(NumberFormatter.density(line.density)),
              _cell(NumberFormatter.carat(line.carat),
                  color: AppColors.accentCarat, bold: true),
              _cell(NumberFormatter.unitPrice(line.unitPrice)),
              _cell(NumberFormatter.amount(line.amount)),
              if (_canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.textMuted),
                  onPressed: () => onDeleteLine!(line),
                  tooltip: 'Supprimer la barre ${line.barNumber}',
                ),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _cell(String text, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
