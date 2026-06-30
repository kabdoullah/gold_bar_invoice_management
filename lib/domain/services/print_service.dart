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
  static const double invoiceNumber = 22.0; // "FACTURE FAC-0001"
  static const double barCount = 18.0; // "Nombre Barres: 5"
  static const double tableHeader = 16.0; // column headers
  static const double tableCell = 18.0; // data cells
  static const double caratCell = 20.0; // carat column — key value (hero)
  static const double totalsLabel = 16.0; // totals labels
  static const double totalsValue = 18.0; // total numbers
  static const double grandTotal = 24.0; // "Montant Total" — biggest
}

/// Generates a PDF faithful to the original desktop software layout and
/// opens the native print/share sheet via [Printing.layoutPdf].
class PrintService {
  PrintService(this._calculator);

  final GoldBarCalculatorService _calculator;

  static final _headerStyle = pw.TextStyle(
    fontSize: PdfFontSizes.tableHeader,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );
  // All data cells are bold — printed numbers read better heavy at arm's
  // length.
  static final _cellStyle = pw.TextStyle(
    fontSize: PdfFontSizes.tableCell,
    fontWeight: pw.FontWeight.bold,
  );
  // Carat is the hero value: dark red on a pale red chip so it stays legible
  // even when the red hue itself is hard to perceive.
  static final _caratStyle = pw.TextStyle(
    fontSize: PdfFontSizes.caratCell,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.red900,
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
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 1),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
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
          decoration: const pw.BoxDecoration(color: PdfColors.grey700),
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
        for (final entry in lines.asMap().entries)
          pw.TableRow(
            // Zebra striping so a wide landscape row stays easy to follow.
            decoration: entry.key.isOdd
                ? const pw.BoxDecoration(color: PdfColors.grey100)
                : null,
            children: [
              _cell(NumberFormatter.amount(entry.value.basePrice)),
              _cell(NumberFormatter.weight(entry.value.grossWeight)),
              _cell(NumberFormatter.weight(entry.value.waterWeight)),
              _cell(NumberFormatter.density(entry.value.density)),
              _caratCell(NumberFormatter.carat(entry.value.carat)),
              _cell(NumberFormatter.unitPrice(entry.value.unitPrice)),
              _cell(NumberFormatter.amount(entry.value.amount)),
            ],
          ),
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
                'Poids Total: ${NumberFormatter.weightTruncated(invoice.totalGrossWeight)}'),
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
              'Eaux Total: ${NumberFormatter.weightTruncated(invoice.totalWaterWeight)}',
            ),
            _totalCell(
              'Densité Totale: ${NumberFormatter.density(global.globalDensity)}',
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        // Grand total on its own full-width boxed line — biggest, framed so it
        // is impossible to miss; never wraps.
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border.all(color: PdfColors.grey800, width: 1.5),
          ),
          child: pw.Text(
            'Montant Total: ${NumberFormatter.amount(invoice.totalAmount)}',
            style: pw.TextStyle(
              fontSize: PdfFontSizes.grandTotal,
              fontWeight: pw.FontWeight.bold,
            ),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      child: pw.Text(
        text,
        style: style ?? _cellStyle,
        textAlign: pw.TextAlign.right,
      ),
    );
  }

  /// Carat data cell rendered as a pale red chip filling the cell — the hero
  /// value, legible even when the red text hue is hard to perceive.
  pw.Widget _caratCell(String text) {
    return pw.Container(
      color: PdfColors.red50,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      alignment: pw.Alignment.centerRight,
      child: pw.Text(text, style: _caratStyle, textAlign: pw.TextAlign.right),
    );
  }
}
