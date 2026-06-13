import 'package:flutter/widgets.dart';

/// Breakpoints: mobile < 600px (horizontally scrollable table),
/// tablet >= 600px (full-width table).
abstract final class Responsive {
  static const double tabletBreakpoint = 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Returns [mobile] below the breakpoint, [tablet] at or above it.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
  }) =>
      isMobile(context) ? mobile : tablet;
}
