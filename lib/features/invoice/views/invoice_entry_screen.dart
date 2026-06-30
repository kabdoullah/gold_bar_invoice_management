import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../viewmodels/invoice_entry_viewmodel.dart';
import '../widgets/backup_reminder_banner.dart';
import '../widgets/bar_entry_card.dart';
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

  late final InvoiceEntryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<InvoiceEntryViewModel>();
    _syncBaseField();
    // Repopulate the base field when a draft is auto-loaded — reactively,
    // never inside build().
    _vm.addListener(_syncBaseField);
  }

  /// Mirrors the VM's basePrice into the field, but only while the field is
  /// untouched, so it never fights the operator's typing.
  void _syncBaseField() {
    if (!mounted) return;
    if (_vm.basePrice != null && _baseCtrl.text.isEmpty) {
      _baseCtrl.text = _formatBase(_vm.basePrice!);
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_syncBaseField);
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
                // Base price — always full width, above both layouts.
                _BasePriceField(controller: _baseCtrl, vm: vm),
                const SizedBox(height: 12),
                Responsive.isTablet(context)
                    ? _buildTabletLayout(vm)
                    : _buildMobileLayout(vm),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile: entry card, then table below, then full-width Save & Print.
  Widget _buildMobileLayout(InvoiceEntryViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _entryCard(vm),
        const SizedBox(height: 16),
        if (vm.lines.isNotEmpty) ...[
          InvoiceTable(
            lines: vm.lines,
            onDeleteLine: (line) => vm.deleteLine(line.id),
            scrollable: true,
          ),
          const SizedBox(height: 8),
          if (vm.invoice != null)
            TotalsWidget(invoice: vm.invoice!, global: vm.globalCaratResult),
          const SizedBox(height: 16),
        ],
        _saveButton(vm),
      ],
    );
  }

  /// Tablet: 200px entry column on the left, table + totals + Save on the
  /// right (flexible, full-width table — no horizontal scroll).
  Widget _buildTabletLayout(InvoiceEntryViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 200, child: _entryCard(vm)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vm.lines.isNotEmpty) ...[
                InvoiceTable(
                  lines: vm.lines,
                  onDeleteLine: (line) => vm.deleteLine(line.id),
                  scrollable: false,
                ),
                const SizedBox(height: 8),
                if (vm.invoice != null)
                  TotalsWidget(invoice: vm.invoice!, global: vm.globalCaratResult),
                const SizedBox(height: 16),
              ],
              _saveButton(vm),
            ],
          ),
        ),
      ],
    );
  }

  Widget _entryCard(InvoiceEntryViewModel vm) => BarEntryCard(
        grossCtrl: _grossCtrl,
        waterCtrl: _waterCtrl,
        grossFocus: _grossFocus,
        onGrossChanged: (v) => vm.setGrossWeight(_parse(v)),
        onWaterChanged: (v) => vm.setWaterWeight(_parse(v)),
        preview: vm.currentPreview,
        canAdd: vm.canAddLine,
        onAdd: () => _onAdd(vm),
      );

  Widget _saveButton(InvoiceEntryViewModel vm) => SaveAndPrintButton(
        enabled: vm.canSaveAndPrint,
        isSaving: vm.isSavingAndPrinting,
        onPressed: () => _onSave(vm),
      );

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
    final colors = AppColors.of(context);
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: colors.textPrimary, fontSize: 16),
      decoration: goldInputDecoration(colors, 'Prix de base'),
      onChanged: (v) => vm.setBasePrice(_InvoiceEntryScreenState._parse(v)),
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
    );
  }
}
