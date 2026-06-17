/// Business constants for gold bar valuation.
///
/// These values are proprietary to the client's pricing method and must
/// never change without explicit confirmation — every stored invoice
/// amount was computed with them.
abstract final class BusinessConstants {
  /// `A` in the carat formula: density of the reference alloy.
  ///
  /// carat = (density - A) × B / density
  static const double referenceAlloyDensity = 10.51;

  /// `B` in the carat formula: conversion factor from density to carats.
  static const double caratConversionFactor = 52.838;

  /// The base market price (`basePrice`) is quoted for this carat purity.
  ///
  /// unitPrice = (basePrice / caratBase) × carat
  static const double caratBase = 22.0;

  /// Default invoice location, shown in the header and PDF.
  static const String defaultLocation = "Côte d'Ivoire";

  /// Above this line count, batch recalculation moves into an isolate
  /// via `compute()`.
  static const int isolateLineThreshold = 50;
}
