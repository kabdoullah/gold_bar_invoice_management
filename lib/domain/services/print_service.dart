import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/business_constants.dart';
import '../../core/utils/number_formatter.dart';
import '../entities/invoice.dart';
import '../entities/invoice_line.dart';
import 'gold_bar_calculator_service.dart';

/// Font size constants for the PDF invoice layout.
/// Intentionally larger than in-app UI sizes — printed paper must be
/// readable at arm's length under workshop conditions, no pinch-zoom.
class PdfFontSizes {
  PdfFontSizes._();

  static const double header = 22.0; // location + date line
  static const double invoiceNumber = 20.0; // "FACTURE FAC-0001"
  static const double barCount = 16.0; // "Nombre Barres: 5"
  static const double tableHeader = 15.0; // column headers
  static const double tableCell = 16.0; // data cells
  static const double caratCell = 16.0; // carat column — key value
  static const double totalsLabel = 15.0; // totals labels
  static const double totalsValue = 17.0; // total numbers
  static const double grandTotal = 22.0; // "Montant Total" — biggest
}

/// Generates a PDF faithful to the original desktop software layout and
/// opens the native print/share sheet via [Printing.layoutPdf].
class PrintService {
  PrintService(this._calculator);

  final GoldBarCalculatorService _calculator;

  static final _headerStyle = pw.TextStyle(
    fontSize: PdfFontSizes.tableHeader,
    fontWeight: pw.FontWeight.bold,
  );
  static const _cellStyle = pw.TextStyle(fontSize: PdfFontSizes.tableCell);
  static final _caratStyle = pw.TextStyle(
    fontSize: PdfFontSizes.caratCell,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.red,
  );
  static final _totalStyle = pw.TextStyle(
    fontSize: PdfFontSizes.totalsValue,
    fontWeight: pw.FontWeight.bold,
  );
  static final _totalCaratStyle = pw.TextStyle(
    fontSize: PdfFontSizes.totalsValue,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.red,
  );

  /// Entry point called by InvoiceDetailViewModel.saveAndPrint().
  /// The native sheet offers both "Print" and "Share".
  Future<void> printInvoice(Invoice invoice, List<InvoiceLine> lines) async {
    final pdf = buildPdf(invoice, lines);
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Facture_${invoice.invoiceNumber}.pdf',
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
          style: pw.TextStyle(
            fontSize: PdfFontSizes.invoiceNumber,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              '${BusinessConstants.defaultLocation} le: '
              '${NumberFormatter.date(invoice.issueDate)}',
              style: pw.TextStyle(
                fontSize: PdfFontSizes.header,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Nombre Barres: ${invoice.barCount}',
              style: pw.TextStyle(
                fontSize: PdfFontSizes.barCount,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
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
    // 2 rows × 2 columns grid.
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
          ],
        ),
        pw.SizedBox(height: 10),
        // Grand total on its own full-width line — biggest, never wraps.
        pw.Text(
          'Montant Total: ${NumberFormatter.amount(invoice.totalAmount)}',
          style: pw.TextStyle(
            fontSize: PdfFontSizes.grandTotal,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// One equal-width cell in the 2-column totals grid.
  pw.Widget _totalCell(String text, {pw.TextStyle? style}) {
    return pw.Expanded(
      child: pw.Text(text, style: style ?? _totalStyle),
    );
  }

  pw.Widget _cell(String text, {pw.TextStyle? style}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        style: style ?? _cellStyle,
        textAlign: pw.TextAlign.right,
      ),
    );
  }
}
