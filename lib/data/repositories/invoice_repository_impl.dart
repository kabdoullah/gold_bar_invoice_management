import 'package:drift/drift.dart';

import '../../core/errors/business_exceptions.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_line.dart';
import '../../domain/repositories/i_invoice_repository.dart';
import '../../domain/services/gold_bar_calculator_service.dart';
import '../local/database/app_database.dart';
import 'invoice_mappers.dart';

/// Drift-backed implementation of [IInvoiceRepository].
class InvoiceRepositoryImpl implements IInvoiceRepository {
  InvoiceRepositoryImpl(this._db, this._calculator);

  final AppDatabase _db;
  final GoldBarCalculatorService _calculator;

  @override
  Stream<List<Invoice>> watchSavedInvoices() => _db.invoiceDao
      .watchSaved()
      .map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<Invoice?> getInvoice(int id) async =>
      (await _db.invoiceDao.getById(id))?.toEntity();

  @override
  Stream<Invoice?> watchInvoice(int id) =>
      _db.invoiceDao.watchById(id).map((r) => r?.toEntity());

  @override
  Future<Invoice?> findDraft() async =>
      (await _db.invoiceDao.findDraft())?.toEntity();

  @override
  Stream<Invoice?> watchDraft() =>
      _db.invoiceDao.watchDraft().map((r) => r?.toEntity());

  @override
  Future<Invoice> createDraft({
    required DateTime issueDate,
    required String location,
    required double basePrice,
  }) async {
    if (basePrice <= 0) {
      throw const InvalidBasePriceException('basePrice must be > 0');
    }
    if (await _db.invoiceDao.findDraft() != null) {
      throw const InvoiceStateException(
        'A draft invoice already exists — resume or discard it first',
      );
    }
    final id = await _db.invoiceDao.insertInvoice(InvoicesCompanion.insert(
      invoiceNumber: await _nextInvoiceNumber(),
      issueDate: issueDate,
      location: Value(location),
      basePrice: basePrice,
    ));
    return (await _requireInvoice(id)).toEntity();
  }

  @override
  Future<void> updateDraftHeader(
    int id, {
    DateTime? issueDate,
    String? location,
    double? basePrice,
  }) async {
    final row = await _requireInvoice(id);
    if (row.status != 'draft') {
      throw const InvoiceStateException('Only a draft can be edited');
    }
    if (basePrice != null && basePrice != row.basePrice && row.barCount > 0) {
      throw const InvoiceStateException(
        'basePrice cannot change once lines exist',
      );
    }
    await _db.invoiceDao.updateFields(
      id,
      InvoicesCompanion(
        issueDate: Value.absentIfNull(issueDate),
        location: Value.absentIfNull(location),
        basePrice: Value.absentIfNull(basePrice),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<InvoiceLine>> getLines(int invoiceId) async =>
      (await _db.invoiceLineDao.getForInvoice(invoiceId))
          .map((r) => r.toEntity())
          .toList();

  @override
  Stream<List<InvoiceLine>> watchLines(int invoiceId) => _db.invoiceLineDao
      .watchForInvoice(invoiceId)
      .map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<InvoiceLine> addLine({
    required int invoiceId,
    required double grossWeight,
    required double waterWeight,
  }) async {
    final invoice = await _requireInvoice(invoiceId);
    if (invoice.status != 'draft') {
      throw const InvoiceStateException(
        'Lines can only be added to a draft invoice',
      );
    }
    final values = _calculator.calculateLine(
      grossWeight: grossWeight,
      waterWeight: waterWeight,
      basePrice: invoice.basePrice,
    );

    return _db.transaction(() async {
      final lineId = await _db.invoiceLineDao.insertLine(
        InvoiceLinesCompanion.insert(
          invoiceId: invoiceId,
          barNumber: await _db.invoiceLineDao.nextBarNumber(invoiceId),
          basePrice: invoice.basePrice,
          grossWeight: grossWeight,
          waterWeight: waterWeight,
          density: values.density,
          carat: values.carat,
          unitPrice: values.unitPrice,
          amount: values.amount,
        ),
      );
      await _refreshTotals(invoiceId);
      final rows = await _db.invoiceLineDao.getForInvoice(invoiceId);
      return rows.firstWhere((l) => l.id == lineId).toEntity();
    });
  }

  @override
  Future<void> deleteLine({required int lineId, required int invoiceId}) {
    return _db.transaction(() async {
      await _db.invoiceLineDao.deleteById(lineId);
      await _refreshTotals(invoiceId);
    });
  }

  @override
  Future<void> finalizeInvoice(int id) async {
    final row = await _requireInvoice(id);
    if (row.status != 'draft') {
      throw const InvoiceStateException('Invoice is already saved');
    }
    if (row.barCount == 0) {
      throw const InvoiceStateException(
        'An invoice needs at least one line to be saved',
      );
    }
    await _db.invoiceDao.updateFields(
      id,
      InvoicesCompanion(
        status: const Value('saved'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> discardDraft(int id) async {
    final row = await _requireInvoice(id);
    if (row.status != 'draft') {
      throw const InvoiceStateException('Only a draft can be discarded');
    }
    await _db.invoiceDao.deleteById(id);
  }

  /// Recomputes the denormalized totals of an invoice from its lines.
  Future<void> _refreshTotals(int invoiceId) async {
    final totals = await _db.invoiceLineDao.totalsForInvoice(invoiceId);
    await _db.invoiceDao.updateFields(
      invoiceId,
      InvoicesCompanion(
        barCount: Value(totals.barCount),
        totalGrossWeight: Value(totals.totalGrossWeight),
        totalWaterWeight: Value(totals.totalWaterWeight),
        totalAmount: Value(totals.totalAmount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Sequential invoice number: FAC-0001, FAC-0002...
  Future<String> _nextInvoiceNumber() async {
    final next = await _db.invoiceDao.maxId() + 1;
    return 'FAC-${next.toString().padLeft(4, '0')}';
  }

  Future<InvoiceRow> _requireInvoice(int id) async {
    final row = await _db.invoiceDao.getById(id);
    if (row == null) {
      throw InvoiceStateException('Invoice $id not found');
    }
    return row;
  }
}
