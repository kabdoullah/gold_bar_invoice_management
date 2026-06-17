import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/business_constants.dart';
import '../../core/utils/number_formatter.dart';
import '../entities/invoice.dart';
import '../entities/invoice_line.dart';
import 'gold_bar_calculator_service.dart';

/// Generates a PDF faithful to the original desktop software layout and
/// opens the native print/share sheet via [Printing.layoutPdf].
class PrintService {
  PrintService(this._calculator);

  final GoldBarCalculatorService _calculator;

  static final _headerStyle = pw.TextStyle(
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
  );
  static const _cellStyle = pw.TextStyle(fontSize: 9);
  static final _caratStyle = pw.TextStyle(
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.red,
  );
  static final _totalStyle = pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
  );
  static final _totalCaratStyle = pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.red,
  );

  /// Entry point called by InvoiceDetailViewModel.saveAndPrint().
  /// The native sheet offers both "Print" and "Share".
  Future<void> printInvoice(Invoice invoice, List<InvoiceLine> lines) async {
    final pdf = buildPdf(invoice, lines);
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNumber}.pdf',
    );
  }

  /// Pure document construction — separated from [printInvoice] so it can
  /// be unit tested without platform channels.
  pw.Document buildPdf(Invoice invoice, List<InvoiceLine> lines) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(invoice),
          pw.SizedBox(height: 12),
          _buildTable(invoice, lines),
          pw.SizedBox(height: 12),
          _buildTotals(invoice, lines),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _buildHeader(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FACTURE ${invoice.invoiceNumber}',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${BusinessConstants.defaultLocation} le: '
              '${NumberFormatter.date(invoice.issueDate)}',
              style: _cellStyle,
            ),
            pw.Text('Nombre Barres: ${invoice.barCount}', style: _cellStyle),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTable(Invoice invoice, List<InvoiceLine> lines) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
        4: pw.FlexColumnWidth(2),
        5: pw.FlexColumnWidth(2.5),
        6: pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            for (final label in [
              'Base',
              'Poids Brut',
              'Eaux',
              'Densité',
              'CARAT',
              'U/BASE',
              'Montant',
            ])
              _cell(label, style: _headerStyle),
          ],
        ),
        for (final line in lines)
          pw.TableRow(children: [
            _cell(NumberFormatter.amount(line.basePrice)),
            _cell(NumberFormatter.weight(line.grossWeight)),
            _cell(NumberFormatter.weight(line.waterWeight)),
            _cell(NumberFormatter.density(line.density)),
            _cell(NumberFormatter.carat(line.carat), style: _caratStyle),
            _cell(NumberFormatter.unitPrice(line.unitPrice)),
            _cell(NumberFormatter.amount(line.amount)),
          ]),
      ],
    );
  }

  pw.Widget _buildTotals(Invoice invoice, List<InvoiceLine> lines) {
    // Invoice-level density/carat recomputed from raw totals — never a sum
    // of per-line values (mirrors the in-app TotalsWidget).
    final global = _calculator.calculateGlobalCarat(
      totalGrossWeight: invoice.totalGrossWeight,
      totalWaterWeight: invoice.totalWaterWeight,
    );
    // 2 rows × 3 columns grid. The 6th cell is empty.
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _totalCell(
                'Poids Total: ${NumberFormatter.weight(invoice.totalGrossWeight)}'),
                _totalCell(
              'Carat Général: ${NumberFormatter.carat(global.globalCarat)}',
              style: _totalCaratStyle,
            ),
            _totalCell(
              'Montant Total: ${NumberFormatter.amount(invoice.totalAmount)}',
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _totalCell(
              'Eaux Total: ${NumberFormatter.weight(invoice.totalWaterWeight)}',
            ),
             _totalCell(
              'Densité Totale: ${NumberFormatter.density(global.globalDensity)}',
            ),
            pw.Expanded(child: pw.SizedBox()),
          ],
        ),
      ],
    );
  }

  /// One equal-width cell in the 3-column totals grid.
  pw.Widget _totalCell(String text, {pw.TextStyle? style}) {
    return pw.Expanded(
      child: pw.Text(text, style: style ?? _totalStyle),
    );
  }

  pw.Widget _cell(String text, {pw.TextStyle? style}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: style ?? _cellStyle,
        textAlign: pw.TextAlign.right,
      ),
    );
  }
}
