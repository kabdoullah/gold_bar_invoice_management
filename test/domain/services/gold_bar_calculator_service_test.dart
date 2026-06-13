import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/core/errors/business_exceptions.dart';
import 'package:gold_bar_invoice_management/domain/services/gold_bar_calculator_service.dart';

void main() {
  group('GoldBarCalculatorService', () {
    final calculator = GoldBarCalculatorService();
    const basePrice = 70200.0;

    test('line 1: grossWeight=430.87, waterWeight=23.67', () {
      final density = calculator.calculateDensity(430.87, 23.67);
      expect(density, closeTo(18.20, 0.01));
      final carat = calculator.calculateCarat(density);
      expect(carat, closeTo(22.32, 0.01));
      final unitPrice = calculator.calculateUnitPrice(basePrice, carat);
      expect(unitPrice, closeTo(71221.09, 1.0));
      final amount = calculator.calculateAmount(unitPrice, 430.87);
      expect(amount, closeTo(30687031.02, 100.0));
    });

    test('line 2: grossWeight=126.39, waterWeight=6.87', () {
      final density = calculator.calculateDensity(126.39, 6.87);
      final carat = calculator.calculateCarat(density);
      expect(carat, closeTo(22.64, 0.01));
      final amount = calculator.calculateAmount(
          calculator.calculateUnitPrice(basePrice, carat), 126.39);
      expect(amount, closeTo(9130689.11, 100.0));
    });

    test('line 3: grossWeight=73.18, waterWeight=3.98', () {
      final density = calculator.calculateDensity(73.18, 3.98);
      final carat = calculator.calculateCarat(density);
      expect(carat, closeTo(22.62, 0.01));
      final amount = calculator.calculateAmount(
          calculator.calculateUnitPrice(basePrice, carat), 73.18);
      expect(amount, closeTo(5282012.85, 100.0));
    });

    test('line 4: grossWeight=37.69, waterWeight=2.06', () {
      final density = calculator.calculateDensity(37.69, 2.06);
      final carat = calculator.calculateCarat(density);
      expect(carat, closeTo(22.47, 0.01));
      final amount = calculator.calculateAmount(
          calculator.calculateUnitPrice(basePrice, carat), 37.69);
      expect(amount, closeTo(2702362.64, 100.0));
    });

    test('line 5: grossWeight=30.22, waterWeight=1.63', () {
      final density = calculator.calculateDensity(30.22, 1.63);
      final carat = calculator.calculateCarat(density);
      expect(carat, closeTo(22.86, 0.01));
      final amount = calculator.calculateAmount(
          calculator.calculateUnitPrice(basePrice, carat), 30.22);
      expect(amount, closeTo(2204373.23, 100.0));
    });

    test('calculateLine matches the step-by-step pipeline for line 1', () {
      final preview = calculator.calculateLine(
        grossWeight: 430.87,
        waterWeight: 23.67,
        basePrice: basePrice,
      );
      expect(preview.density, closeTo(18.20, 0.01));
      expect(preview.carat, closeTo(22.32, 0.01));
      expect(preview.unitPrice, closeTo(71221.09, 1.0));
      expect(preview.amount, closeTo(30687031.02, 100.0));
    });

    group('truncation (faithful to original software)', () {
      test('density is truncated, not rounded: 30.22/1.63 → 18.53', () {
        expect(calculator.calculateDensity(30.22, 1.63), 18.53);
      });

      test('carat is truncated, not rounded: density 18.53 → 22.86', () {
        expect(calculator.calculateCarat(18.53), 22.86);
      });

      test('density 18.20 → carat 22.32 (raw 22.3255 truncated)', () {
        expect(calculator.calculateCarat(18.20), 22.32);
      });
    });

    group('validation', () {
      test('zero waterWeight throws InvalidWeightException', () {
        expect(() => calculator.calculateDensity(430.87, 0),
            throwsA(isA<InvalidWeightException>()));
      });

      test('negative grossWeight throws InvalidWeightException', () {
        expect(() => calculator.calculateDensity(-1, 23.67),
            throwsA(isA<InvalidWeightException>()));
      });

      test('waterWeight >= grossWeight throws InvalidWeightException', () {
        expect(() => calculator.calculateDensity(23.67, 430.87),
            throwsA(isA<InvalidWeightException>()));
      });

      test('zero basePrice throws InvalidBasePriceException', () {
        expect(() => calculator.calculateUnitPrice(0, 22.32),
            throwsA(isA<InvalidBasePriceException>()));
      });
    });
  });
}
