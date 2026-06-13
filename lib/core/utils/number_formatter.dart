import 'package:intl/intl.dart';

/// FR-locale formatting shared by the UI and the PDF: space as thousands
/// separator, comma as decimal, always 2 decimals.
///
/// Example: 30687031.02 → "30 687 031,02"
abstract final class NumberFormatter {
  static final NumberFormat _decimal = NumberFormat('#,##0.00', 'fr_FR');

  /// intl's fr_FR grouping separator is a narrow no-break space (U+202F),
  /// which the PDF base fonts cannot encode — normalize to a plain space.
  static String _fr(double value) => _decimal
      .format(value)
      .replaceAll('\u202F', ' ')
      .replaceAll('\u00A0', ' ');

  static String amount(double value) => _fr(value);

  static String weight(double value) => _fr(value);

  static String carat(double value) => _fr(value);

  static String density(double value) => _fr(value);

  static String unitPrice(double value) => _fr(value);

  /// Invoice header date: "06/06/2026".
  static String date(DateTime value) => DateFormat('dd/MM/yyyy').format(value);
}
