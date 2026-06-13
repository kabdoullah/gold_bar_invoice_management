import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_line.dart';
import '../../domain/entities/invoice_status.dart';
import '../local/database/app_database.dart';

/// Drift row → domain entity mapping. The reverse direction goes through
/// companions built inside the repository (inserts never carry a full row).
extension InvoiceRowMapper on InvoiceRow {
  Invoice toEntity() => Invoice(
        id: id,
        invoiceNumber: invoiceNumber,
        issueDate: issueDate,
        location: location,
        basePrice: basePrice,
        status: InvoiceStatus.fromDb(status),
        barCount: barCount,
        totalGrossWeight: totalGrossWeight,
        totalWaterWeight: totalWaterWeight,
        totalAmount: totalAmount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension InvoiceLineRowMapper on InvoiceLineRow {
  InvoiceLine toEntity() => InvoiceLine(
        id: id,
        invoiceId: invoiceId,
        barNumber: barNumber,
        basePrice: basePrice,
        grossWeight: grossWeight,
        waterWeight: waterWeight,
        density: density,
        carat: carat,
        unitPrice: unitPrice,
        amount: amount,
      );
}
