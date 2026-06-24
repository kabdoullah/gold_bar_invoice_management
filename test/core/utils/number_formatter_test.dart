import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/core/utils/number_formatter.dart';

void main() {
  group('NumberFormatter.weightTruncated — troncature, pas arrondi', () {
    test('bruit flottant 698.34999999 → 698,35 (4-déc round le sauve)', () {
      expect(NumberFormatter.weightTruncated(698.34999999), '698,35');
    });

    test('vraie 3e décimale 698.357 → 698,35 (tronqué, pas 698,36)', () {
      expect(NumberFormatter.weightTruncated(698.357), '698,35');
    });

    test('vraie 3e décimale 38.219 → 38,21 (tronqué, pas 38,22)', () {
      expect(NumberFormatter.weightTruncated(38.219), '38,21');
    });

    test('valeur exacte 38.21 → 38,21', () {
      expect(NumberFormatter.weightTruncated(38.21), '38,21');
    });

    test('zéro → 0,00', () {
      expect(NumberFormatter.weightTruncated(0), '0,00');
    });

    test('milliers groupés avec espace : 1234.567 → 1 234,56', () {
      expect(NumberFormatter.weightTruncated(1234.567), '1 234,56');
    });
  });
}
