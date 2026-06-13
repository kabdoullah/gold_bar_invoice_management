import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/services/backup_service.dart';
import '../viewmodels/invoice_list_viewmodel.dart';
import '../widgets/backup_reminder_banner.dart';
import '../widgets/draft_banner.dart';

/// Home screen: saved invoices, DraftBanner when a draft exists,
/// FAB to start a new invoice.
class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => InvoiceListViewModel(
        ctx.read<IInvoiceRepository>(),
        ctx.read<BackupService>(),
      ),
      child: const _InvoiceListView(),
    );
  }
}

class _InvoiceListView extends StatelessWidget {
  const _InvoiceListView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup_outlined),
            tooltip: 'Sauvegarde & Restauration',
            onPressed: () async {
              await context.push<void>('/backup');
              if (context.mounted) {
                context
                    .read<InvoiceListViewModel>()
                    .refreshBackupStatus();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Facture'),
        onPressed: () {
          final draft = vm.draft;
          if (draft != null) {
            // Single-draft rule: resume instead of creating a second one.
            context.push('/invoices/${draft.id}');
          } else {
            context.push('/invoices/new');
          }
        },
      ),
      body: Column(
        children: [
          if (vm.shouldShowBackupReminder)
            BackupReminderBanner(
              message: vm.backupReminderMessage,
              onBackupNow: () async {
                await context.push<void>('/backup');
                if (context.mounted) {
                  context
                      .read<InvoiceListViewModel>()
                      .refreshBackupStatus();
                }
              },
            ),
          if (vm.draft != null)
            DraftBanner(
              draftDate: vm.draft!.createdAt,
              onResume: () => context.push('/invoices/${vm.draft!.id}'),
              onDiscard: () => _confirmDiscard(context, vm),
            ),
          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                vm.error!,
                style: const TextStyle(color: AppColors.syncError),
              ),
            ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.invoices.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune facture enregistrée',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: vm.invoices.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _InvoiceTile(invoice: vm.invoices[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDiscard(
      BuildContext context, InvoiceListViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner le brouillon ?'),
        content: const Text(
            'La facture non terminée et toutes ses barres seront supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.syncError,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.discardDraft();
    }
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        invoice.invoiceNumber,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${NumberFormatter.date(invoice.issueDate)} — '
        '${invoice.barCount} barre${invoice.barCount > 1 ? 's' : ''}',
        style: const TextStyle(color: AppColors.textMuted),
      ),
      trailing: Text(
        NumberFormatter.amount(invoice.totalAmount),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => context.push('/invoices/${invoice.id}'),
    );
  }
}
