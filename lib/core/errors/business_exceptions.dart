/// Typed business exceptions.
///
/// Thrown by domain services and repositories; ViewModels catch them and
/// expose a user-readable message — they must never reach the widget layer
/// unhandled.
sealed class BusinessException implements Exception {
  const BusinessException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A weight input is invalid (zero, negative, or waterWeight >= grossWeight,
/// which is physically impossible for gold).
final class InvalidWeightException extends BusinessException {
  const InvalidWeightException(super.message);
}

/// The base market price is invalid (zero or negative).
final class InvalidBasePriceException extends BusinessException {
  const InvalidBasePriceException(super.message);
}

/// An invoice was not found, or an operation does not apply to its
/// current status (e.g. adding a line to a saved invoice).
final class InvoiceStateException extends BusinessException {
  const InvoiceStateException(super.message);
}
