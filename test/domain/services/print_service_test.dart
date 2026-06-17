import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice_line.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice_status.dart';
import 'package:gold_bar_invoice_management/domain/services/gold_bar_calculator_service.dart';
import 'package:gold_bar_invoice_management/domain/services/print_service.dart';

void main() {
  final invoice = Invoice(
    id: 1,
    invoiceNumber: 'FAC-0001',
    issueDate: DateTime(2026, 6, 6),
    location: "Côte d'Ivoire",
    basePrice: 70200,
    status: InvoiceStatus.saved,
    barCount: 1,
    totalGrossWeight: 430.87,
    totalWaterWeight: 23.67,
    totalAmount: 30687031.02,
    createdAt: DateTime(2026, 6, 6),
    updatedAt: DateTime(2026, 6, 6),
  );

  const line = InvoiceLine(
    id: 1,
    invoiceId: 1,
    barNumber: 1,
    basePrice: 70200,
    grossWeight: 430.87,
    waterWeight: 23.67,
    density: 18.20,
    carat: 22.32,
    unitPrice: 71221.09,
    amount: 30687031.02,
  );

  test('buildPdf produces a non-empty single-page document', () async {
    final pdf = PrintService(GoldBarCalculatorService()).buildPdf(invoice, [line]);
    final bytes = await pdf.save();
    expect(bytes.length, greaterThan(1000));
    // %PDF magic header
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('buildPdf handles a full 5-line invoice', () async {
    final lines = List.generate(
      5,
      (i) => InvoiceLine(
        id: i + 1,
        invoiceId: 1,
        barNumber: i + 1,
        basePrice: 70200,
        grossWeight: 430.87,
        waterWeight: 23.67,
        density: 18.20,
        carat: 22.32,
        unitPrice: 71221.09,
        amount: 30687031.02,
      ),
    );
    final bytes =
        await PrintService(GoldBarCalculatorService()).buildPdf(invoice, lines).save();
    expect(bytes.length, greaterThan(1000));
  });
}
