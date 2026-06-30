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
          _EditableBasePrice(
            basePrice: invoice.basePrice,
            enabled: !vm.isMutating,
            onCommit: (value) => vm.updateBasePriceOfSelectedInvoice(value),
          ),
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

/// Editable base price field with auto-save on blur. Changing it re-prices
/// every line of the invoice (handled by the VM/repository). On an invalid
/// value (empty / not a number / <= 0) the field reverts to the stored price.
class _EditableBasePrice extends StatefulWidget {
  const _EditableBasePrice({
    required this.basePrice,
    required this.onCommit,
    required this.enabled,
  });

  final double                      basePrice;
  final Future<bool> Function(double basePrice) onCommit;
  final bool                        enabled;

  @override
  State<_EditableBasePrice> createState() => _EditableBasePriceState();
}

class _EditableBasePriceState extends State<_EditableBasePrice> {
  final _controller = TextEditingController();
  final _focus      = FocusNode();
  bool _committing = false;

  @override
  void initState() {
    super.initState();
    _controller.text = _editText(widget.basePrice);
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _EditableBasePrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh from storage only when the operator isn't editing.
    if (!_focus.hasFocus) _controller.text = _editText(widget.basePrice);
  }

  void _onFocusChange() {
    if (_focus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_focus.hasFocus) _maybeCommit();
    });
  }

  Future<void> _maybeCommit() async {
    if (_committing) return;
    final value = _parse(_controller.text);
    if (value == null || value <= 0) {
      _revert();
      return;
    }
    if (value == widget.basePrice) return;
    _committing = true;
    final ok = await widget.onCommit(value);
    _committing = false;
    if (!ok && mounted) _revert();
  }

  void _revert() => _controller.text = _editText(widget.basePrice);

  static double? _parse(String v) =>
      v.trim().isEmpty ? null : double.tryParse(v.replaceAll(',', '.'));

  static String _editText(double v) => v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return TextField(
      controller: _controller,
      focusNode: _focus,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _focus.unfocus(),
      style: TextStyle(
          color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Prix de base',
        labelStyle: TextStyle(color: colors.textSecondary),
        filled: true,
        fillColor: colors.surface,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.accentAction, width: 1),
        ),
      ),
    );
  }
}
