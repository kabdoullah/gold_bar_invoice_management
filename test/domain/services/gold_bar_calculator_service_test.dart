import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/core/errors/business_exceptions.dart';
import 'package:gold_bar_invoice_management/domain/services/gold_bar_calculator_service.dart';

/// The 2-decimal value the UI/PDF show for carat. NumberFormatter rounds
/// (intl NumberFormat), which recovers the original truncated carat from
/// its float32 representation (22.31999969… → 22.32).
double display2(double v) => (v * 100).round() / 100;

void main() {
  group('GoldBarCalculatorService — reproduces desktop to the cent', () {
    final calc = GoldBarCalculatorService();
    const base = 70200.0;

    // ── Density: truncated, not rounded ────────────────────────────
    group('calculateDensity (truncate2)', () {
      test('430.87 / 23.67 → 18.20', () {
        expect(calc.calculateDensity(430.87, 23.67), 18.20);
      });
      test('126.39 / 6.87 → 18.39', () {
        expect(calc.calculateDensity(126.39, 6.87), 18.39);
      });
      test('73.18 / 3.98 → 18.38', () {
        expect(calc.calculateDensity(73.18, 3.98), 18.38);
      });
      test('37.69 / 2.06 → 18.29', () {
        expect(calc.calculateDensity(37.69, 2.06), 18.29);
      });
      test('30.22 / 1.63 → 18.53 (truncated from 18.53988, NOT 18.54)', () {
        expect(calc.calculateDensity(30.22, 1.63), 18.53);
      });
    });

    // ── Carat: truncated then cast to 32-bit float ─────────────────
    // The returned double is float32 precision (22.32 → 22.31999969…),
    // so it displays as "22.32" but is not exactly 22.32. Assert on the
    // 2-decimal display, plus a tight tolerance on the raw value.
    group('calculateCarat (truncate2 + float32)', () {
      void expectCarat(double density, double display) {
        final c = calc.calculateCarat(density);
        expect(display2(c), display, reason: '2-decimal display for $density');
        expect(c, closeTo(display, 0.001),
            reason: 'raw float32 value near $display');
      }

      test('density 18.20 → 22.32 (raw 22.3255 truncated)', () {
        expectCarat(18.20, 22.32);
      });
      test('density 18.39 → 22.64', () => expectCarat(18.39, 22.64));
      test('density 18.38 → 22.62', () => expectCarat(18.38, 22.62));
      test('density 18.29 → 22.47', () => expectCarat(18.29, 22.47));
      test('density 18.53 → 22.86 (truncated from 22.8688, NOT 22.87)', () {
        expectCarat(18.53, 22.86);
      });
    });

    // ── End-to-end: amounts must match desktop EXACTLY ─────────────
    group('calculateLine — full pipeline vs desktop reference', () {
      test('line 1: 430.87 / 23.67 → 30 687 031.02', () {
        final r =
            calc.calculateLine(grossWeight: 430.87, waterWeight: 23.67, basePrice: base);
        expect(r.density, 18.20);
        expect(display2(r.carat), 22.32);
        expect(r.amount, 30687031.02);
      });
      test('line 2: 126.39 / 6.87 → 9 130 689.11', () {
        final r =
            calc.calculateLine(grossWeight: 126.39, waterWeight: 6.87, basePrice: base);
        expect(display2(r.carat), 22.64);
        expect(r.amount, 9130689.11);
      });
      test('line 3: 73.18 / 3.98 → 5 282 012.85', () {
        final r =
            calc.calculateLine(grossWeight: 73.18, waterWeight: 3.98, basePrice: base);
        expect(display2(r.carat), 22.62);
        expect(r.amount, 5282012.85);
      });
      test('line 4: 37.69 / 2.06 → 2 702 362.64', () {
        final r =
            calc.calculateLine(grossWeight: 37.69, waterWeight: 2.06, basePrice: base);
        expect(display2(r.carat), 22.47);
        expect(r.amount, 2702362.64);
      });
      test('line 5: 30.22 / 1.63 → 2 204 373.23', () {
        final r =
            calc.calculateLine(grossWeight: 30.22, waterWeight: 1.63, basePrice: base);
        expect(display2(r.carat), 22.86);
        expect(r.amount, 2204373.23);
      });

      test('sum of all 5 lines = 50 006 468.85', () {
        const inputs = [
          (430.87, 23.67),
          (126.39, 6.87),
          (73.18, 3.98),
          (37.69, 2.06),
          (30.22, 1.63),
        ];
        final total = inputs
            .map((i) => calc
                .calculateLine(
                    grossWeight: i.$1, waterWeight: i.$2, basePrice: base)
                .amount)
            .fold(0.0, (a, b) => a + b);
        expect((total * 100).round() / 100, 50006468.85);
      });
    });

    group('validation', () {
      test('zero waterWeight throws', () {
        expect(() => calc.calculateDensity(430.87, 0),
            throwsA(isA<InvalidWeightException>()));
      });
      test('negative grossWeight throws', () {
        expect(() => calc.calculateDensity(-1, 23.67),
            throwsA(isA<InvalidWeightException>()));
      });
      test('waterWeight >= grossWeight throws', () {
        expect(() => calc.calculateDensity(23.67, 430.87),
            throwsA(isA<InvalidWeightException>()));
      });
      test('zero basePrice throws', () {
        expect(() => calc.calculateUnitPrice(0, 22.32),
            throwsA(isA<InvalidBasePriceException>()));
      });
    });
  });
}
