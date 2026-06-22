import 'dart:convert';

import '../local/dao/invoice_dao.dart';
import '../local/dao/invoice_line_dao.dart';
import '../local/database/app_database.dart';

/// A serialized backup: its JSON payload plus the suggested file name.
///
/// Platform-agnostic — holds no `dart:io` File so the same value works on
/// mobile and on web (PWA).
class BackupPayload {
  const BackupPayload({required this.fileName, required this.json});

  final String fileName;
  final String json;
}

/// Serializes all saved invoices and their lines from Drift into a structured
/// JSON backup payload (string + suggested filename).
///
/// Only invoices with `status = 'saved'` are included — drafts are excluded.
class ExportService {
  ExportService(this._invoiceDao, this._invoiceLineDao, this._schemaVersion);

  final InvoiceDao _invoiceDao;
  final InvoiceLineDao _invoiceLineDao;
  final int _schemaVersion;

  /// Exports all saved invoices + their lines to a JSON payload.
  /// Filename: `gold_invoices_backup_YYYY-MM-DD_HHmmss.json`
  Future<BackupPayload> exportToJson() async {
    final invoiceRows = await _invoiceDao.getSaved();

    final invoicesJson = <Map<String, dynamic>>[];
    final linesJson = <Map<String, dynamic>>[];

    for (final row in invoiceRows) {
      invoicesJson.add(_invoiceToJson(row));
      final lines = await _invoiceLineDao.getForInvoice(row.id);
      for (final line in lines) {
        linesJson.add(_lineToJson(line));
      }
    }

    final backup = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': '1.0.0',
      'schemaVersion': _schemaVersion,
      'invoices': invoicesJson,
      'invoiceLines': linesJson,
    };

    final now = DateTime.now();
    final ts = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    return BackupPayload(
      fileName: 'gold_invoices_backup_$ts.json',
      json: jsonEncode(backup),
    );
  }

  Map<String, dynamic> _invoiceToJson(InvoiceRow row) => {
        'id': row.id,
        'invoiceNumber': row.invoiceNumber,
        'issueDate': row.issueDate.toUtc().toIso8601String(),
        'location': row.location,
        'basePrice': row.basePrice,
        'status': row.status,
        'barCount': row.barCount,
        'totalGrossWeight': row.totalGrossWeight,
        'totalWaterWeight': row.totalWaterWeight,
        'totalAmount': row.totalAmount,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _lineToJson(InvoiceLineRow row) => {
        'id': row.id,
        'invoiceId': row.invoiceId,
        'barNumber': row.barNumber,
        'basePrice': row.basePrice,
        'grossWeight': row.grossWeight,
        'waterWeight': row.waterWeight,
        'density': row.density,
        'carat': row.carat,
        'unitPrice': row.unitPrice,
        'amount': row.amount,
      };
}
