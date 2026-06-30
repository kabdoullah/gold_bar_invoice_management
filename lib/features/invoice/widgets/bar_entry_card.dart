import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice_line_preview.dart';

/// VM-agnostic gross/water entry card with a live preview and an "Ajouter
/// barre" button.
///
/// Shared by the entry screen (binds to [InvoiceEntryViewModel]) and the
/// editable invoice detail panel (binds to [InvoiceHistoryViewModel]). The
/// host owns the controllers/focus and decides how [preview]/[canAdd] are
/// computed — this widget only renders and forwards callbacks.
class BarEntryCard extends StatelessWidget {
  const BarEntryCard({
    super.key,
    required this.grossCtrl,
    required this.waterCtrl,
    required this.onGrossChanged,
    required this.onWaterChanged,
    required this.preview,
    required this.canAdd,
    required this.onAdd,
    this.grossFocus,
  });

  final TextEditingController grossCtrl;
  final TextEditingController waterCtrl;
  final FocusNode?            grossFocus;
  final ValueChanged<String>  onGrossChanged;
  final ValueChanged<String>  onWaterChanged;

  /// Live preview of the bar being typed, or null to show placeholders.
  final InvoiceLinePreview? preview;

  /// Whether "Ajouter barre" is enabled.
  final bool canAdd;

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _WeightField(
                  label: 'Poids (g)',
                  controller: grossCtrl,
                  focusNode: grossFocus,
                  onChanged: onGrossChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WeightField(
                  label: 'Eaux (g)',
                  controller: waterCtrl,
                  onChanged: onWaterChanged,
                ),
              ),
            ],
          ),
          Divider(color: colors.border, height: 20),
          preview != null
              ? _PreviewBlock(preview: preview!)
              : const _PreviewPlaceholder(),
          const SizedBox(height: 12),
          _AddBarButton(enabled: canAdd, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _WeightField extends StatelessWidget {
  const _WeightField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.focusNode,
  });

  final String                label;
  final TextEditingController controller;
  final ValueChanged<String>  onChanged;
  final FocusNode?            focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: colors.textPrimary, fontSize: 15),
      decoration: goldInputDecoration(colors, label),
      onChanged: onChanged,
    );
  }
}

// ── Preview ──────────────────────────────────────────────────────────

class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({required this.preview});

  final InvoiceLinePreview preview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PreviewRow('Densité', NumberFormatter.density(preview.density)),
        _PreviewRow('Carat', NumberFormatter.carat(preview.carat),
            isRed: true),
        _PreviewRow('U/BASE', NumberFormatter.unitPrice(preview.unitPrice)),
        _PreviewRow('Montant', NumberFormatter.amount(preview.amount)),
      ],
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PreviewRow('Densité', '—'),
        _PreviewRow('Carat', '—', isRed: true),
        _PreviewRow('U/BASE', '—'),
        _PreviewRow('Montant', '—'),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow(this.label, this.value, {this.isRed = false});

  final String label;
  final String value;
  final bool   isRed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isRed ? colors.accentCarat : colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add bar ──────────────────────────────────────────────────────────

class _AddBarButton extends StatelessWidget {
  const _AddBarButton({required this.enabled, required this.onPressed});

  final bool         enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Ajouter barre'),
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentAction,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.border,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ── Shared input decoration ──────────────────────────────────────────

/// Outlined, dense, theme-aware field decoration used by every numeric
/// input in the invoice flows (base price + weight fields).
InputDecoration goldInputDecoration(AppColorScheme colors, String label) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colors.border, width: 0.5),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: colors.textSecondary),
    filled: true,
    fillColor: colors.surface,
    isDense: true,
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.accentAction, width: 1),
    ),
  );
}
