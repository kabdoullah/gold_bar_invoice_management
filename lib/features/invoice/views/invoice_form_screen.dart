import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../viewmodels/invoice_form_viewmodel.dart';

/// Creation of a new invoice: location, issue date and base price.
/// On submit the draft is persisted immediately and the app navigates
/// to the detail screen to start adding bars.
class InvoiceFormScreen extends StatelessWidget {
  const InvoiceFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          InvoiceFormViewModel(context.read<IInvoiceRepository>()),
      child: const _InvoiceFormView(),
    );
  }
}

class _InvoiceFormView extends StatelessWidget {
  const _InvoiceFormView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceFormViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Facture')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: vm.location,
              decoration: const InputDecoration(labelText: 'Lieu'),
              onChanged: vm.setLocation,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickDate(context, vm),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(NumberFormatter.date(vm.issueDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Base (prix de référence)',
                hintText: '70200',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) =>
                  vm.setBasePrice(double.tryParse(value.replaceAll(',', '.'))),
            ),
            const SizedBox(height: 24),
            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: AppColors.syncError),
                ),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Créer la facture'),
              onPressed: vm.canSubmit ? () => _submit(context, vm) : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, InvoiceFormViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) vm.setIssueDate(picked);
  }

  Future<void> _submit(BuildContext context, InvoiceFormViewModel vm) async {
    final invoice = await vm.submit();
    if (invoice != null && context.mounted) {
      // Replace the form so "back" from the detail returns to the list.
      context.pushReplacement('/invoices/${invoice.id}');
    }
  }
}
