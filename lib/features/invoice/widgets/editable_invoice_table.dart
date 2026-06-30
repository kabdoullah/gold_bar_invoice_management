import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice_line.dart';

/// Dense tabular display of invoice lines with **inline-editable** Poids
/// Brut / Eaux columns — used to edit the values of an already-saved
/// invoice. All other columns (Base, Densité, CARAT, U/BASE, Montant) are
/// read-only and refresh after a commit.
///
/// Auto-save happens when focus leaves a whole row (both fields blurred):
/// the current Poids/Eaux are parsed (FR comma accepted); if the pair is
/// valid and changed, [onCommit] fires; otherwise the fields revert to the
/// stored values. Lines are not added or removed here — the bar count is
/// fixed.
///
/// [scrollable] mirrors [InvoiceTable]: true wraps in a horizontal scroll
/// with fixed column widths (mobile); false flexes to fill the width
/// (tablet). [enabled] is false while a commit is in flight.
class EditableInvoiceTable extends StatefulWidget {
  const EditableInvoiceTable({
    super.key,
    required this.lines,
    required this.onCommit,
    this.scrollable = false,
    this.enabled = true,
  });

  final List<InvoiceLine> lines;

  /// Persists an edited line. Returns true on success; on false the table
  /// reverts the row's fields to the stored values.
  final Future<bool> Function(InvoiceLine line, double gross, double water)
      onCommit;

  final bool scrollable;
  final bool enabled;

  @override
  State<EditableInvoiceTable> createState() => _EditableInvoiceTableState();
}

class _EditableInvoiceTableState extends State<EditableInvoiceTable> {
  final Map<int, _RowEditState> _rows = {};
  bool _committing = false;

  static const _headerLabels = [
    'Base',
    'Poids Brut',
    'Eaux',
    'Densité',
    'CARAT',
    'U/BASE',
    'Montant',
  ];

  @override
  void initState() {
    super.initState();
    _syncRows();
  }

  @override
  void didUpdateWidget(covariant EditableInvoiceTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRows();
  }

  /// Creates row state for new lines, refreshes stored text for rows that are
  /// not currently being edited, and disposes state for removed lines.
  void _syncRows() {
    final ids = widget.lines.map((l) => l.id).toSet();
    for (final removed in _rows.keys.toList()) {
      if (!ids.contains(removed)) {
        _rows.remove(removed)!.dispose();
      }
    }
    for (final line in widget.lines) {
      final row = _rows.putIfAbsent(line.id, () {
        final r = _RowEditState();
        r.grossFocus.addListener(() => _onRowFocusChange(line.id));
        r.waterFocus.addListener(() => _onRowFocusChange(line.id));
        return r;
      });
      // Only overwrite the visible text when the operator isn't editing this
      // row — never fight live typing.
      if (!row.grossFocus.hasFocus && !row.waterFocus.hasFocus) {
        row.grossCtrl.text = _editText(line.grossWeight);
        row.waterCtrl.text = _editText(line.waterWeight);
      }
    }
  }

  void _onRowFocusChange(int lineId) {
    // Defer to the end of the frame so focus moving between the two fields of
    // the same row settles before we decide the row was blurred.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final row = _rows[lineId];
      if (row == null) return;
      if (row.grossFocus.hasFocus || row.waterFocus.hasFocus) return;
      _maybeCommit(lineId);
    });
  }

  Future<void> _maybeCommit(int lineId) async {
    if (_committing) return;
    final row = _rows[lineId];
    final line = widget.lines.where((l) => l.id == lineId).firstOrNull;
    if (row == null || line == null) return;

    final gross = _parse(row.grossCtrl.text);
    final water = _parse(row.waterCtrl.text);

    // Invalid input (empty / not a number) → revert, no persistence.
    if (gross == null || water == null) {
      _revert(row, line);
      return;
    }
    // Unchanged → nothing to do.
    if (gross == line.grossWeight && water == line.waterWeight) return;

    _committing = true;
    final ok = await widget.onCommit(line, gross, water);
    _committing = false;
    // On a rejected pair (e.g. water >= gross) revert to the stored values.
    if (!ok && mounted) _revert(row, line);
  }

  void _revert(_RowEditState row, InvoiceLine line) {
    row.grossCtrl.text = _editText(line.grossWeight);
    row.waterCtrl.text = _editText(line.waterWeight);
  }

  static double? _parse(String v) =>
      v.trim().isEmpty ? null : double.tryParse(v.replaceAll(',', '.'));

  /// Plain, parseable text for an edit field (FR comma, no grouping).
  static String _editText(double v) => v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  @override
  void dispose() {
    for (final row in _rows.values) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (widget.scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildTable(colors, flexible: false),
      );
    }
    return _buildTable(colors, flexible: true);
  }

  Widget _buildTable(AppColorScheme colors, {required bool flexible}) {
    const fixedWidths = [100.0, 110.0, 100.0, 80.0, 80.0, 110.0, 140.0];
    return Table(
      border: TableBorder.all(color: colors.border, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        for (var i = 0; i < fixedWidths.length; i++)
          i: flexible
              ? const FlexColumnWidth()
              : FixedColumnWidth(fixedWidths[i]),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: colors.tableHeader),
          children: [
            for (final label in _headerLabels) _headerCell(colors, label),
          ],
        ),
        for (final line in widget.lines) _dataRow(colors, line),
      ],
    );
  }

  TableRow _dataRow(AppColorScheme colors, InvoiceLine line) {
    final row = _rows[line.id]!;
    return TableRow(
      decoration: BoxDecoration(color: colors.surface),
      children: [
        _cell(colors, NumberFormatter.amount(line.basePrice),
            color: colors.textDimmed),
        _editCell(colors, row.grossCtrl, row.grossFocus),
        _editCell(colors, row.waterCtrl, row.waterFocus),
        _cell(colors, NumberFormatter.density(line.density)),
        _cell(colors, NumberFormatter.carat(line.carat),
            color: colors.accentCarat, bold: true),
        _cell(colors, NumberFormatter.unitPrice(line.unitPrice)),
        _cell(colors, NumberFormatter.amount(line.amount)),
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

  Widget _editCell(
    AppColorScheme colors,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: widget.enabled,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => focusNode.unfocus(),
        style: TextStyle(color: colors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          filled: true,
          fillColor: colors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.accentAction, width: 1),
          ),
        ),
      ),
    );
  }
}

/// Per-row editing state: one controller + focus node for each editable
/// field. Lives as long as its line is present in the table.
class _RowEditState {
  final grossCtrl  = TextEditingController();
  final waterCtrl  = TextEditingController();
  final grossFocus = FocusNode();
  final waterFocus = FocusNode();

  void dispose() {
    grossCtrl.dispose();
    waterCtrl.dispose();
    grossFocus.dispose();
    waterFocus.dispose();
  }
}
