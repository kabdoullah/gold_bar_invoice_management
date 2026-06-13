import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/invoice_line_preview.dart';
import '../viewmodels/invoice_entry_viewmodel.dart';
import '../widgets/backup_reminder_banner.dart';
import '../widgets/invoice_table.dart';
import '../widgets/save_and_print_button.dart';
import '../widgets/totals_widget.dart';

/// The single home screen: shared base price + bar entry card with live
/// preview + line table + Save & Print. Reads [InvoiceEntryViewModel]
/// provided above [AppShell].
///
/// Stateful only to own the three [TextEditingController]s and the gross
/// focus node — clear-on-add and clear-on-save are driven off the VM's
/// returned success flags, not its notifications.
class InvoiceEntryScreen extends StatefulWidget {
  const InvoiceEntryScreen({super.key});

  @override
  State<InvoiceEntryScreen> createState() => _InvoiceEntryScreenState();
}

class _InvoiceEntryScreenState extends State<InvoiceEntryScreen> {
  final _baseCtrl   = TextEditingController();
  final _grossCtrl  = TextEditingController();
  final _waterCtrl  = TextEditingController();
  final _grossFocus = FocusNode();

  @override
  void dispose() {
    _baseCtrl.dispose();
    _grossCtrl.dispose();
    _waterCtrl.dispose();
    _grossFocus.dispose();
    super.dispose();
  }

  static double? _parse(String v) =>
      v.trim().isEmpty ? null : double.tryParse(v.replaceAll(',', '.'));

  Future<void> _onAdd(InvoiceEntryViewModel vm) async {
    final ok = await vm.addLine();
    if (!ok || !mounted) return;
    _grossCtrl.clear();
    _waterCtrl.clear();
    vm.clearWeightInputs();
    _grossFocus.requestFocus();
  }

  Future<void> _onSave(InvoiceEntryViewModel vm) async {
    final ok = await vm.saveAndPrint();
    if (!ok || !mounted) return;
    _baseCtrl.clear();
    _grossCtrl.clear();
    _waterCtrl.clear();
    _grossFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceEntryViewModel>();

    // Repopulate the base field when a draft is auto-loaded (only while
    // the field is untouched, so it never fights the operator's typing).
    if (vm.basePrice != null && _baseCtrl.text.isEmpty) {
      _baseCtrl.text = _formatBase(vm.basePrice!);
    }

    return Column(
      children: [
        if (vm.shouldShowBackupReminder)
          BackupReminderBanner(
            message: vm.backupReminderMessage,
            onBackupNow: () async {
              await context.push('/backup');
              vm.refreshBackupStatus();
            },
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BasePriceField(controller: _baseCtrl, vm: vm),
                const SizedBox(height: 12),
                _EntryCard(
                  vm: vm,
                  grossCtrl: _grossCtrl,
                  waterCtrl: _waterCtrl,
                  grossFocus: _grossFocus,
                  onAdd: () => _onAdd(vm),
                ),
                const SizedBox(height: 16),
                if (vm.lines.isNotEmpty) ...[
                  InvoiceTable(
                    lines: vm.lines,
                    onDeleteLine: (line) => vm.deleteLine(line.id),
                  ),
                  const SizedBox(height: 8),
                  if (vm.invoice != null)
                    TotalsWidget(invoice: vm.invoice!, lines: vm.lines),
                  const SizedBox(height: 16),
                ],
                SaveAndPrintButton(
                  enabled: vm.canSaveAndPrint,
                  isSaving: vm.isSavingAndPrinting,
                  onPressed: () => _onSave(vm),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatBase(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}

// ── Base price ───────────────────────────────────────────────────────

class _BasePriceField extends StatelessWidget {
  const _BasePriceField({required this.controller, required this.vm});

  final TextEditingController controller;
  final InvoiceEntryViewModel vm;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: _inputDecoration('Prix de base'),
      onChanged: (v) => vm.setBasePrice(_InvoiceEntryScreenState._parse(v)),
    );
  }
}

// ── Entry card ───────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.vm,
    required this.grossCtrl,
    required this.waterCtrl,
    required this.grossFocus,
    required this.onAdd,
  });

  final InvoiceEntryViewModel vm;
  final TextEditingController grossCtrl;
  final TextEditingController waterCtrl;
  final FocusNode             grossFocus;
  final VoidCallback          onAdd;

  @override
  Widget build(BuildContext context) {
    final fields = Row(
      children: [
        Expanded(
          child: _WeightField(
            label: 'Poids (g)',
            controller: grossCtrl,
            focusNode: grossFocus,
            onChanged: (v) =>
                vm.setGrossWeight(_InvoiceEntryScreenState._parse(v)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _WeightField(
            label: 'Eaux (g)',
            controller: waterCtrl,
            onChanged: (v) =>
                vm.setWaterWeight(_InvoiceEntryScreenState._parse(v)),
          ),
        ),
      ],
    );

    final preview = vm.currentPreview != null
        ? _PreviewBlock(preview: vm.currentPreview!)
        : const _PreviewPlaceholder();

    final addButton = _AddBarButton(enabled: vm.canAddLine, onPressed: onAdd);

    final Widget body = Responsive.isTablet(context)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: fields),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    preview,
                    const SizedBox(height: 12),
                    addButton,
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              fields,
              const Divider(color: AppColors.tableBorder, height: 20),
              preview,
              const SizedBox(height: 12),
              addButton,
            ],
          );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundTable,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tableBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: body,
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
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: _inputDecoration(label),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isRed ? AppColors.accentCarat : AppColors.textPrimary,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Ajouter barre'),
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tableHeader,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.tableBorder,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ── Shared input decoration ──────────────────────────────────────────

InputDecoration _inputDecoration(String label) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColors.tableBorder, width: 0.5),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.backgroundTable,
    isDense: true,
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.tableHeader, width: 1),
    ),
  );
}
