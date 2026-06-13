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
        syncedAt: syncedAt,
      );

  /// JSON payload for the sync queue / Supabase.
  Map<String, dynamic> toSyncJson() => {
        'id': id,
        'invoice_number': invoiceNumber,
        'issue_date': issueDate.toIso8601String(),
        'location': location,
        'base_price': basePrice,
        'status': status,
        'bar_count': barCount,
        'total_gross_weight': totalGrossWeight,
        'total_water_weight': totalWaterWeight,
        'total_amount': totalAmount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
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
        syncedAt: syncedAt,
      );

  Map<String, dynamic> toSyncJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'bar_number': barNumber,
        'base_price': basePrice,
        'gross_weight': grossWeight,
        'water_weight': waterWeight,
        'density': density,
        'carat': carat,
        'unit_price': unitPrice,
        'amount': amount,
      };
}
