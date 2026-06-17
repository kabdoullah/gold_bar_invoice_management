import 'dart:typed_data';

import '../../core/constants/business_constants.dart';
import '../../core/errors/business_exceptions.dart';
import '../entities/invoice_line_preview.dart';

/// Encapsulates the four valuation formulas for a gold bar, applied in
/// order: density → carat → unitPrice → amount.
///
/// Reproduces the original desktop software TO THE CENT. Two fidelity
/// rules, both verified against the client's capture data (see the unit
/// tests — all five reference lines match exactly, total = 50 006 468.85):
///
/// 1. density and carat are TRUNCATED (not rounded) to 2 decimals before
///    feeding the next formula (e.g. 30.22/1.63 → density 18.53, not
///    18.54; carat 22.86, not 22.87).
/// 2. the carat is then stored as a 32-bit FLOAT before computing
///    unitPrice. The desktop app (an older single-precision codebase)
///    held carat in a `float`, so 22.32 is really 22.31999969… That tiny
///    deviation, carried into a double unitPrice × gross and rounded to
///    cents, is exactly what produces the desktop amounts. Computing the
///    carat purely in `double` is off by up to 0.42 per line / 0.50 on
///    the total — close, but not faithful.
///
/// unitPrice keeps full double precision (it is the operand of the amount
/// product); amount is rounded to 2 decimals at the end, matching the
/// desktop's per-line cent rounding.
class GoldBarCalculatorService {
  /// Truncates toward zero at 2 decimals: 18.53988 → 18.53 (never 18.54).
  static double _truncate2(double value) =>
      (value * 100).truncateToDouble() / 100;

  /// Rounds half-up at 2 decimals: 30687031.0483 → 30687031.05.
  static double _round2(double value) => (value * 100).round() / 100;

  /// Reusable single-element buffer for the 32-bit float round-trip.
  /// Safe to reuse: the main isolate is single-threaded and `compute()`
  /// runs in a separate isolate with its own copy of this static.
  static final Float32List _f32 = Float32List(1);

  /// Casts [value] to 32-bit float precision and back to double, matching
  /// how the original desktop software stored carat in a `float`.
  /// Example: 22.32 → 22.319999694824219.
  static double _toFloat32(double value) {
    _f32[0] = value;
    return _f32[0];
  }

  /// Calculates the density of a gold bar using the hydrostatic
  /// (Archimedes) method.
  ///
  /// Formula: density = truncate2(grossWeight / waterWeight)
  ///
  /// The result is truncated to 2 decimals, matching the original
  /// software (30.22 / 1.63 = 18.53988 → 18.53, not 18.54).
  ///
  /// Example: 430.87 / 23.67 = 18.20
  ///
  /// [grossWeight] weight of the bar in grams (in air)
  /// [waterWeight] weight of the bar submerged in water
  ///
  /// Throws [InvalidWeightException] if either weight is not strictly
  /// positive or if waterWeight >= grossWeight (physically impossible).
  double calculateDensity(double grossWeight, double waterWeight) {
    if (grossWeight <= 0) {
      throw const InvalidWeightException('grossWeight must be > 0');
    }
    if (waterWeight <= 0) {
      throw const InvalidWeightException('waterWeight must be > 0');
    }
    if (waterWeight >= grossWeight) {
      throw const InvalidWeightException(
        'waterWeight must be lower than grossWeight',
      );
    }
    return _truncate2(grossWeight / waterWeight);
  }

  /// Calculates the gold purity in carats from the measured density.
  ///
  /// Formula: carat = float32(truncate2((density - A) × B / density))
  /// where A = 10.51 (reference alloy density)
  /// and   B = 52.838 (conversion factor)
  ///
  /// The result is truncated to 2 decimals, matching the original
  /// software (22.3255 → 22.32, not 22.33), then cast to 32-bit float
  /// precision because the desktop app stored carat in a `float`. The
  /// returned value is therefore NOT exactly the 2-decimal number
  /// (22.32 → 22.319999694…); it displays as "22.32" via
  /// `NumberFormatter.carat()`, but feeds [calculateUnitPrice] at float
  /// precision so the line amount reproduces the desktop to the cent.
  ///
  /// Example: density = 18.20 → (18.20 - 10.51) × 52.838 / 18.20 = 22.32
  ///
  /// [density] calculated by [calculateDensity]
  double calculateCarat(double density) {
    const a = BusinessConstants.referenceAlloyDensity;
    const b = BusinessConstants.caratConversionFactor;
    return _toFloat32(_truncate2((density - a) * b / density));
  }

  /// Calculates the unit price per gram ("U/BASE") from the market base
  /// price and the carat purity.
  ///
  /// Formula: unitPrice = (basePrice / 22) × carat
  /// (the base price is quoted for 22-carat gold)
  ///
  /// Example: (70200 / 22) × 22.32 = 71 221.09
  ///
  /// [basePrice] reference market price (same for all bars in an invoice)
  /// [carat] calculated by [calculateCarat]
  ///
  /// Throws [InvalidBasePriceException] if basePrice is not strictly
  /// positive.
  double calculateUnitPrice(double basePrice, double carat) {
    if (basePrice <= 0) {
      throw const InvalidBasePriceException('basePrice must be > 0');
    }
    return (basePrice / BusinessConstants.caratBase) * carat;
  }

  /// Calculates the total amount for one invoice line (one gold bar).
  ///
  /// Formula: amount = round2(unitPrice × grossWeight)
  ///
  /// Rounded to 2 decimals here (not just at display) to match the
  /// desktop's per-line cent rounding — line totals are summed from these
  /// stored values, so the invoice total reproduces the desktop exactly.
  ///
  /// Example: 71221.0899… × 430.87 = 30 687 031.02
  ///
  /// [unitPrice] full-precision result of [calculateUnitPrice]
  /// [grossWeight] weight of the bar in grams
  double calculateAmount(double unitPrice, double grossWeight) {
    return _round2(unitPrice * grossWeight);
  }

  /// Calculates the invoice-level "Densité Totale" and "Carat Général".
  ///
  /// CRITICAL BUSINESS RULE — confirmed explicitly by the client:
  /// this is NOT a sum or average of the per-line density/carat values. It
  /// is recalculated from scratch using the invoice's raw weight totals.
  ///
  /// Unlike the per-line path, the totals row uses plain ROUNDING (not the
  /// truncation + 32-bit-float fidelity of [calculateDensity]/
  /// [calculateCarat]). The carat is computed from the already-rounded
  /// density, which is what reproduces the client's reference total:
  ///
  ///   globalDensity = round2(totalGrossWeight / totalWaterWeight)
  ///   globalCarat   = round2((globalDensity - A) × B / globalDensity)
  ///
  /// Example: totalGrossWeight=698.35, totalWaterWeight=38.21
  ///   globalDensity = round2(18.27662…) = 18.28
  ///   globalCarat   = round2((18.28 - 10.51) × 52.838 / 18.28) = 22.46
  /// (feeding the un-rounded density 18.27662 would give 22.45, not 22.46).
  ///
  /// Returns zeros for an empty invoice (either total non-positive) so the
  /// totals row shows 0 rather than throwing.
  ///
  /// [totalGrossWeight] sum of all line grossWeight values in the invoice
  /// [totalWaterWeight] sum of all line waterWeight values in the invoice
  GlobalCaratResult calculateGlobalCarat({
    required double totalGrossWeight,
    required double totalWaterWeight,
  }) {
    if (totalGrossWeight <= 0 || totalWaterWeight <= 0) {
      return const GlobalCaratResult(globalDensity: 0, globalCarat: 0);
    }
    const a = BusinessConstants.referenceAlloyDensity;
    const b = BusinessConstants.caratConversionFactor;
    final globalDensity = _round2(totalGrossWeight / totalWaterWeight);
    final globalCarat = _round2((globalDensity - a) * b / globalDensity);
    return GlobalCaratResult(
      globalDensity: globalDensity,
      globalCarat: globalCarat,
    );
  }

  /// Runs the four formulas in order and returns the transient preview
  /// used both by the real-time entry form and by line persistence.
  InvoiceLinePreview calculateLine({
    required double grossWeight,
    required double waterWeight,
    required double basePrice,
  }) {
    final density = calculateDensity(grossWeight, waterWeight);
    final carat = calculateCarat(density);
    final unitPrice = calculateUnitPrice(basePrice, carat);
    final amount = calculateAmount(unitPrice, grossWeight);
    return InvoiceLinePreview(
      density: density,
      carat: carat,
      unitPrice: unitPrice,
      amount: amount,
    );
  }
}

/// Holds the invoice-level density and carat, calculated from raw totals —
/// never from summing or averaging individual line values.
class GlobalCaratResult {
  final double globalDensity;
  final double globalCarat;

  const GlobalCaratResult({
    required this.globalDensity,
    required this.globalCarat,
  });
}
