import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/services/backup_service.dart';
import '../../../domain/services/gold_bar_calculator_service.dart';
import '../../../domain/services/print_service.dart';
import '../viewmodels/invoice_detail_viewmodel.dart';
import '../widgets/invoice_table.dart';
import '../widgets/save_and_print_button.dart';
import '../widgets/totals_widget.dart';
import 'invoice_line_form_sheet.dart';

/// Invoice detail: header, dense line table, totals, "Ajouter Barre" FAB
/// (draft only) and the Save & Print button.
class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  final int invoiceId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InvoiceDetailViewModel(
        context.read<IInvoiceRepository>(),
        context.read<GoldBarCalculatorService>(),
        context.read<PrintService>(),
        invoiceId:     invoiceId,
        backupService: context.read<BackupService>(),
      ),
      child: const _InvoiceDetailView(),
    );
  }
}

class _InvoiceDetailView extends StatelessWidget {
  const _InvoiceDetailView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceDetailViewModel>();
    final invoice = vm.invoice;

    if (vm.isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Facture introuvable',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          if (invoice.isDraft)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  'BROUILLON',
                  style: TextStyle(
                    color: AppColors.draftWarning,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: invoice.isDraft
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Ajouter Barre'),
              onPressed: () => showInvoiceLineFormSheet(context, vm),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(invoice: invoice, vm: vm),
          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                vm.error!,
                style: const TextStyle(color: AppColors.syncError),
              ),
            ),
          Expanded(
            child: vm.lines.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune barre — appuyez sur "Ajouter Barre"',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: InvoiceTable(
                      lines: vm.lines,
                      onDeleteLine: invoice.isDraft
                          ? (line) => vm.deleteLine(line.id)
                          : null,
                    ),
                  ),
          ),
          TotalsWidget(invoice: invoice),
          if (invoice.isDraft)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SaveAndPrintButton(
                enabled: vm.canSaveAndPrint,
                isSaving: vm.isSavingAndPrinting,
                onPressed: () => vm.saveAndPrint(),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.invoice, required this.vm});

  final Invoice invoice;
  final InvoiceDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: invoice.isDraft ? () => _pickDate(context) : null,
              child: Text(
                '${invoice.location} le: '
                '${NumberFormatter.date(invoice.issueDate)}'
                '${invoice.isDraft ? '  ✎' : ''}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
          Text(
            'Nombre Barres: ${invoice.barCount}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: invoice.issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      await vm.updateHeader(issueDate: picked);
    }
  }
}
