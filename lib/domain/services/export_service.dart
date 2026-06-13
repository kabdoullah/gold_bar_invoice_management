import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/local/dao/invoice_dao.dart';
import '../../data/local/dao/invoice_line_dao.dart';
import '../../data/local/database/app_database.dart';

/// Serializes all saved invoices and their lines from Drift into a structured
/// JSON backup file written to the device's temp directory.
///
/// Only invoices with `status = 'saved'` are included — drafts are excluded.
class ExportService {
  ExportService(this._invoiceDao, this._invoiceLineDao, this._schemaVersion);

  final InvoiceDao _invoiceDao;
  final InvoiceLineDao _invoiceLineDao;
  final int _schemaVersion;

  /// Exports all saved invoices + their lines to a JSON temp file.
  /// Filename: `gold_invoices_backup_YYYY-MM-DD_HHmmss.json`
  Future<File> exportToJson() async {
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

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final ts = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/gold_invoices_backup_$ts.json');
    await file.writeAsString(jsonEncode(backup));
    return file;
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
