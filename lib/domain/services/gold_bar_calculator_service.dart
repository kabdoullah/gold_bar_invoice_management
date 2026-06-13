import '../../core/constants/business_constants.dart';
import '../../core/errors/business_exceptions.dart';
import '../entities/invoice_line_preview.dart';

/// Encapsulates the four valuation formulas for a gold bar, applied in
/// order: density → carat → unitPrice → amount.
///
/// Faithful to the original desktop software: density and carat are
/// TRUNCATED (not rounded) to 2 decimals before being fed into the next
/// formula. Without this the verification capture data cannot be
/// reproduced (e.g. line 30.22/1.63: raw carat 22.88 vs expected 22.86,
/// amount off by ~2 400). unitPrice and amount keep full precision and
/// are rounded only at display time.
class GoldBarCalculatorService {
  /// Truncates toward zero at 2 decimals: 18.53988 → 18.53 (never 18.54).
  static double _truncate2(double value) =>
      (value * 100).truncateToDouble() / 100;

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
  /// Formula: carat = truncate2((density - A) × B / density)
  /// where A = 10.51 (reference alloy density)
  /// and   B = 52.838 (conversion factor)
  ///
  /// The result is truncated to 2 decimals, matching the original
  /// software (22.3255 → 22.32, not 22.33). The truncated carat is what
  /// feeds [calculateUnitPrice].
  ///
  /// Example: density = 18.20 → (18.20 - 10.51) × 52.838 / 18.20 = 22.32
  ///
  /// [density] calculated by [calculateDensity]
  double calculateCarat(double density) {
    const a = BusinessConstants.referenceAlloyDensity;
    const b = BusinessConstants.caratConversionFactor;
    return _truncate2((density - a) * b / density);
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
  /// Formula: amount = unitPrice × grossWeight
  ///
  /// Example: 71221.09 × 430.87 = 30 687 031.02
  ///
  /// [unitPrice] calculated by [calculateUnitPrice]
  /// [grossWeight] weight of the bar in grams
  double calculateAmount(double unitPrice, double grossWeight) {
    return unitPrice * grossWeight;
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
