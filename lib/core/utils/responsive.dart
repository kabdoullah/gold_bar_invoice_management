import 'package:flutter/widgets.dart';

/// Breakpoints: mobile < 600px (horizontally scrollable table),
/// tablet >= 600px (full-width table).
abstract final class Responsive {
  static const double tabletBreakpoint = 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;
}
