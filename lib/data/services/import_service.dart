import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

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
      data = jsonDecode(content) as Map<String, dynamic>;
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

    await _db.transaction(() async {
      // Cascade delete removes lines of saved invoices automatically.
      await (_db.delete(_db.invoices)
            ..where((i) => i.status.equals('saved')))
          .go();

      for (final inv in invoicesData) {
        if (inv is! Map<String, dynamic>) {
          throw const CorruptedBackupException('Invalid invoice entry');
        }
        await _db.into(_db.invoices).insert(_invoiceFromJson(inv));
      }

      for (final line in linesData) {
        if (line is! Map<String, dynamic>) {
          throw const CorruptedBackupException('Invalid line entry');
        }
        await _db.into(_db.invoiceLines).insert(_lineFromJson(line));
      }
    });
  }

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
