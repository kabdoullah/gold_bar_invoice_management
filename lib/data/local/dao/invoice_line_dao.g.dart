// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_line_dao.dart';

// ignore_for_file: type=lint
mixin _$InvoiceLineDaoMixin on DatabaseAccessor<AppDatabase> {
  $InvoicesTable get invoices => attachedDatabase.invoices;
  $InvoiceLinesTable get invoiceLines => attachedDatabase.invoiceLines;
  InvoiceLineDaoManager get managers => InvoiceLineDaoManager(this);
}

class InvoiceLineDaoManager {
  final _$InvoiceLineDaoMixin _db;
  InvoiceLineDaoManager(this._db);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db.attachedDatabase, _db.invoices);
  $$InvoiceLinesTableTableManager get invoiceLines =>
      $$InvoiceLinesTableTableManager(_db.attachedDatabase, _db.invoiceLines);
}
