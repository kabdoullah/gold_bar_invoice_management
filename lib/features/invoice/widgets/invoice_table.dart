import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice_line.dart';

/// Dense tabular display of invoice lines, faithful to the original
/// desktop software.
///
/// Scroll is the parent's decision: [scrollable] true wraps the table in a
/// horizontal [SingleChildScrollView] with fixed column widths (mobile);
/// false renders flexible full-width columns (tablet). The parent picks
/// based on [Responsive].
///
/// Carat column always red; Base column dimmed (shared fixed value).
class InvoiceTable extends StatelessWidget {
  const InvoiceTable({
    super.key,
    required this.lines,
    this.onDeleteLine,
    this.scrollable = false,
  });

  final List<InvoiceLine> lines;

  /// Non-null while the invoice is a draft — shows a delete icon per row.
  final void Function(InvoiceLine line)? onDeleteLine;

  /// When true, wrap in a horizontal scroll with fixed column widths.
  /// When false, columns flex to fill the available width.
  final bool scrollable;

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
    final colors = AppColors.of(context);
    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildTable(colors, flexible: false),
      );
    }
    return _buildTable(colors, flexible: true);
  }

  Widget _buildTable(AppColorScheme colors, {required bool flexible}) {
    const fixedWidths = [100.0, 90.0, 80.0, 80.0, 80.0, 110.0, 140.0];
    return Table(
      border: TableBorder.all(color: colors.border, width: 1),
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
          decoration: BoxDecoration(color: colors.tableHeader),
          children: [
            for (final label in _headerLabels) _headerCell(colors, label),
            if (_canDelete) const SizedBox.shrink(),
          ],
        ),
        for (final line in lines)
          TableRow(
            decoration: BoxDecoration(color: colors.surface),
            children: [
              _cell(colors, NumberFormatter.amount(line.basePrice),
                  color: colors.textDimmed),
              _cell(colors, NumberFormatter.weight(line.grossWeight)),
              _cell(colors, NumberFormatter.weight(line.waterWeight)),
              _cell(colors, NumberFormatter.density(line.density)),
              _cell(colors, NumberFormatter.carat(line.carat),
                  color: colors.accentCarat, bold: true),
              _cell(colors, NumberFormatter.unitPrice(line.unitPrice)),
              _cell(colors, NumberFormatter.amount(line.amount)),
              if (_canDelete)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: colors.textSecondary),
                  onPressed: () => onDeleteLine!(line),
                  tooltip: 'Supprimer la barre ${line.barNumber}',
                ),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(AppColorScheme colors, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _cell(AppColorScheme colors, String text,
      {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: color ?? colors.textPrimary,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
