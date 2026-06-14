import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/backup_exceptions.dart';
import '../local/database/app_database.dart';

/// Reads a JSON backup file and restores its contents into the local Drift DB,
/// replacing all existing saved invoices.
///
/// - DRAFT invoices are never touched.
/// - SAVED invoices are replaced atomically (DELETE then INSERT).
/// - The entire operation runs in a single transaction — any error rolls back.
class ImportService {
  ImportService(this._db);

  final AppDatabase _db;

  /// Restores saved invoices from [backupFile] into Drift.
  ///
  /// Throws [SchemaVersionMismatchException] if the backup schema differs.
  /// Throws [CorruptedBackupException] if parsing fails.
  Future<void> importFromJson(File backupFile) async {
    final String content;
    try {
      content = await backupFile.readAsString();
    } catch (e) {
      throw CorruptedBackupException('Cannot read file: $e');
    }

    final Map<String, dynamic> data;
    try {
      data = await compute(_decodeJson, content);
    } catch (e) {
      throw CorruptedBackupException('Invalid JSON: $e');
    }

    final backupVersion = data['schemaVersion'] as int?;
    if (backupVersion == null) {
      throw const CorruptedBackupException('Missing schemaVersion');
    }
    if (backupVersion != _db.schemaVersion) {
      throw SchemaVersionMismatchException(
        backupVersion: backupVersion,
        currentVersion: _db.schemaVersion,
      );
    }

    final invoicesData = data['invoices'];
    final linesData = data['invoiceLines'];
    if (invoicesData is! List || linesData is! List) {
      throw const CorruptedBackupException(
          'Missing or invalid invoices / invoiceLines');
    }

    // Map + validate BEFORE the transaction: turns raw cast errors into the
    // documented CorruptedBackupException, and keeps the transaction short.
    final List<InvoicesCompanion> invoiceRows;
    final List<InvoiceLinesCompanion> lineRows;
    try {
      invoiceRows = invoicesData
          .map((e) => _invoiceFromJson(e as Map<String, dynamic>))
          .toList();
      lineRows = linesData
          .map((e) => _lineFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CorruptedBackupException('Invalid backup entry: $e');
    }

    await _db.transaction(() async {
      // Cascade delete removes lines of saved invoices automatically.
      await (_db.delete(_db.invoices)
            ..where((i) => i.status.equals('saved')))
          .go();

      await _db.batch((b) {
        b.insertAll(_db.invoices, invoiceRows);
        b.insertAll(_db.invoiceLines, lineRows);
      });
    });
  }

  /// Top-level-callable decode for `compute()` (must not capture `this`).
  static Map<String, dynamic> _decodeJson(String s) =>
      jsonDecode(s) as Map<String, dynamic>;

  InvoicesCompanion _invoiceFromJson(Map<String, dynamic> m) {
    return InvoicesCompanion(
      id: Value(m['id'] as int),
      invoiceNumber: Value(m['invoiceNumber'] as String),
      issueDate: Value(DateTime.parse(m['issueDate'] as String)),
      location: Value(m['location'] as String),
      basePrice: Value((m['basePrice'] as num).toDouble()),
      status: Value(m['status'] as String),
      barCount: Value(m['barCount'] as int),
      totalGrossWeight: Value((m['totalGrossWeight'] as num).toDouble()),
      totalWaterWeight: Value((m['totalWaterWeight'] as num).toDouble()),
      totalAmount: Value((m['totalAmount'] as num).toDouble()),
      createdAt: Value(DateTime.parse(m['createdAt'] as String)),
      updatedAt: Value(DateTime.parse(m['updatedAt'] as String)),
    );
  }

  InvoiceLinesCompanion _lineFromJson(Map<String, dynamic> m) {
    return InvoiceLinesCompanion(
      id: Value(m['id'] as int),
      invoiceId: Value(m['invoiceId'] as int),
      barNumber: Value(m['barNumber'] as int),
      basePrice: Value((m['basePrice'] as num).toDouble()),
      grossWeight: Value((m['grossWeight'] as num).toDouble()),
      waterWeight: Value((m['waterWeight'] as num).toDouble()),
      density: Value((m['density'] as num).toDouble()),
      carat: Value((m['carat'] as num).toDouble()),
      unitPrice: Value((m['unitPrice'] as num).toDouble()),
      amount: Value((m['amount'] as num).toDouble()),
    );
  }
}
