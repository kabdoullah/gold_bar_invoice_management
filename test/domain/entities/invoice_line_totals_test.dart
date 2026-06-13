import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice_line.dart';

void main() {
  InvoiceLine line(double density, double carat) => InvoiceLine(
        id: 1,
        invoiceId: 1,
        barNumber: 1,
        basePrice: 70200,
        grossWeight: 100,
        waterWeight: 5,
        density: density,
        carat: carat,
        unitPrice: 1,
        amount: 1,
      );

  test('totalDensity and totalCarat are the raw sums of the lines', () {
    final lines = [line(18.20, 22.32), line(18.53, 22.86), line(17.95, 22.62)];

    expect(lines.totalDensity, closeTo(54.68, 1e-9));
    expect(lines.totalCarat, closeTo(67.80, 1e-9));
  });

  test('empty list totals are zero', () {
    expect(<InvoiceLine>[].totalDensity, 0.0);
    expect(<InvoiceLine>[].totalCarat, 0.0);
  });
}
