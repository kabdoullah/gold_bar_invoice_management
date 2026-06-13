import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice_line_preview.dart';
import '../viewmodels/invoice_detail_viewmodel.dart';

/// Opens the bottom sheet to enter a new bar (grossWeight + waterWeight)
/// with a real-time calculation preview before confirming.
Future<void> showInvoiceLineFormSheet(
  BuildContext context,
  InvoiceDetailViewModel vm,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundTable,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: _InvoiceLineForm(vm: vm),
    ),
  );
}

class _InvoiceLineForm extends StatefulWidget {
  const _InvoiceLineForm({required this.vm});

  final InvoiceDetailViewModel vm;

  @override
  State<_InvoiceLineForm> createState() => _InvoiceLineFormState();
}

class _InvoiceLineFormState extends State<_InvoiceLineForm> {
  final _grossController = TextEditingController();
  final _waterController = TextEditingController();
  InvoiceLinePreview? _preview;
  bool _isAdding = false;

  @override
  void dispose() {
    _grossController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  double? get _gross =>
      double.tryParse(_grossController.text.replaceAll(',', '.'));

  double? get _water =>
      double.tryParse(_waterController.text.replaceAll(',', '.'));

  /// Recomputed on every keystroke — persists nothing.
  void _refreshPreview() {
    final gross = _gross;
    final water = _water;
    setState(() {
      _preview = (gross == null || water == null)
          ? null
          : widget.vm.previewLine(gross, water);
    });
  }

  Future<void> _addBar() async {
    setState(() => _isAdding = true);
    final ok = await widget.vm.addLine(_gross!, _water!);
    if (!mounted) return;
    setState(() => _isAdding = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nouvelle Barre',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _grossController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Poids Brut'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _refreshPreview(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _waterController,
                  decoration: const InputDecoration(labelText: 'Eaux'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _refreshPreview(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PreviewBlock(preview: _preview),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: _isAdding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Ajouter Barre'),
                onPressed:
                    (_preview != null && !_isAdding) ? _addBar : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({required this.preview});

  final InvoiceLinePreview? preview;

  @override
  Widget build(BuildContext context) {
    final p = preview;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.tableBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _row('Densité', p == null ? '—' : NumberFormatter.density(p.density)),
          _row(
            'Carat',
            p == null ? '—' : NumberFormatter.carat(p.carat),
            valueColor: AppColors.accentCarat,
            bold: true,
          ),
          _row('U/BASE',
              p == null ? '—' : NumberFormatter.unitPrice(p.unitPrice)),
          _row('Montant', p == null ? '—' : NumberFormatter.amount(p.amount),
              bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {Color valueColor = AppColors.textPrimary, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
