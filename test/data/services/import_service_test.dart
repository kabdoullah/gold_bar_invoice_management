import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/core/errors/backup_exceptions.dart';
import 'package:gold_bar_invoice_management/data/local/database/app_database.dart';
import 'package:gold_bar_invoice_management/data/services/import_service.dart';

void main() {
  late AppDatabase db;
  late ImportService service;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = ImportService(db);
    tempDir = Directory.systemTemp.createTempSync('import_test');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  // Writes [backup] to a temp JSON file and returns it.
  File backupFile(Object backup) {
    final file = File('${tempDir.path}/backup.json');
    file.writeAsStringSync(
      backup is String ? backup : jsonEncode(backup),
    );
    return file;
  }

  Map<String, dynamic> invoiceJson({
    int id = 100,
    String number = 'FAC-0100',
    String status = 'saved',
  }) =>
      {
        'id': id,
        'invoiceNumber': number,
        'issueDate': '2026-06-06T00:00:00.000Z',
        'location': "Côte d'Ivoire",
        'basePrice': 70200.0,
        'status': status,
        'barCount': 1,
        'totalGrossWeight': 430.87,
        'totalWaterWeight': 23.67,
        'totalAmount': 30687031.02,
        'createdAt': '2026-06-06T00:00:00.000Z',
        'updatedAt': '2026-06-06T00:00:00.000Z',
      };

  Map<String, dynamic> lineJson({int id = 1, int invoiceId = 100}) => {
        'id': id,
        'invoiceId': invoiceId,
        'barNumber': 1,
        'basePrice': 70200.0,
        'grossWeight': 430.87,
        'waterWeight': 23.67,
        'density': 18.20,
        'carat': 22.32,
        'unitPrice': 71221.09,
        'amount': 30687031.02,
      };

  Map<String, dynamic> validBackup({
    List<Map<String, dynamic>>? invoices,
    List<Map<String, dynamic>>? lines,
    int schemaVersion = 2,
  }) =>
      {
        'exportedAt': '2026-06-06T00:00:00.000Z',
        'appVersion': '1.0.0',
        'schemaVersion': schemaVersion,
        'invoices': invoices ?? [invoiceJson()],
        'invoiceLines': lines ?? [lineJson()],
      };

  group('ImportService', () {
    test('restores invoices and lines from a valid backup', () async {
      await service.importFromJson(backupFile(validBackup()));

      final saved = await db.invoiceDao.getSaved();
      expect(saved.map((i) => i.invoiceNumber), ['FAC-0100']);
      expect(saved.single.totalAmount, closeTo(30687031.02, 0.001));

      final lines = await db.invoiceLineDao.getForInvoice(100);
      expect(lines.single.carat, 22.32);
      expect(lines.single.grossWeight, 430.87);
    });

    test('replaces existing saved invoices but preserves drafts', () async {
      // Pre-existing saved invoice (should be wiped) + a draft (should survive).
      await db.invoiceDao.insertInvoice(InvoicesCompanion.insert(
        invoiceNumber: 'FAC-OLD',
        issueDate: DateTime(2026, 1, 1),
        basePrice: 60000,
        status: const drift.Value('saved'),
      ));
      final draftId = await db.invoiceDao.insertInvoice(
        InvoicesCompanion.insert(
          invoiceNumber: 'FAC-DRAFT',
          issueDate: DateTime(2026, 1, 1),
          basePrice: 60000,
        ),
      );

      await service.importFromJson(backupFile(validBackup()));

      final saved = await db.invoiceDao.getSaved();
      expect(saved.map((i) => i.invoiceNumber), ['FAC-0100']); // old gone

      final draft = await db.invoiceDao.findDraft();
      expect(draft?.id, draftId); // draft untouched
      expect(draft?.invoiceNumber, 'FAC-DRAFT');
    });

    test('throws SchemaVersionMismatchException on schema mismatch', () async {
      final file = backupFile(validBackup(schemaVersion: 999));
      expect(
        () => service.importFromJson(file),
        throwsA(isA<SchemaVersionMismatchException>()),
      );
    });

    test('throws CorruptedBackupException on invalid JSON', () async {
      final file = backupFile('{ not valid json');
      expect(
        () => service.importFromJson(file),
        throwsA(isA<CorruptedBackupException>()),
      );
    });

    test('throws CorruptedBackupException on missing schemaVersion', () async {
      final file = backupFile({
        'invoices': [invoiceJson()],
        'invoiceLines': [lineJson()],
      });
      expect(
        () => service.importFromJson(file),
        throwsA(isA<CorruptedBackupException>()),
      );
    });

    test('throws CorruptedBackupException when invoices is not a list',
        () async {
      final file = backupFile({
        'schemaVersion': 2,
        'invoices': 'oops',
        'invoiceLines': [],
      });
      expect(
        () => service.importFromJson(file),
        throwsA(isA<CorruptedBackupException>()),
      );
    });

    test('throws CorruptedBackupException on a malformed row entry', () async {
      // basePrice missing → cast `as num` fails → wrapped, not raw TypeError.
      final badInvoice = invoiceJson()..remove('basePrice');
      final file = backupFile(validBackup(invoices: [badInvoice]));
      expect(
        () => service.importFromJson(file),
        throwsA(isA<CorruptedBackupException>()),
      );
    });

    test('malformed row leaves the database untouched (atomic)', () async {
      await db.invoiceDao.insertInvoice(InvoicesCompanion.insert(
        invoiceNumber: 'FAC-OLD',
        issueDate: DateTime(2026, 1, 1),
        basePrice: 60000,
        status: const drift.Value('saved'),
      ));

      final badInvoice = invoiceJson()..remove('basePrice');
      final file = backupFile(validBackup(invoices: [badInvoice]));

      await expectLater(
        service.importFromJson(file),
        throwsA(isA<CorruptedBackupException>()),
      );

      // Row mapping fails BEFORE the transaction → old saved data intact.
      final saved = await db.invoiceDao.getSaved();
      expect(saved.map((i) => i.invoiceNumber), ['FAC-OLD']);
    });
  });
}
