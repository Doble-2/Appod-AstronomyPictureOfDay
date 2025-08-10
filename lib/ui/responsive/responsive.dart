import 'package:flutter/material.dart';

/// Breakpoints centralizados para la app.
class AppBreakpoints {
  static const double xs = 0; // mobile
  static const double sm = 600; // mobile landscape / tablet chica
  static const double md = 905; // tablet grande / desktop pequeño
  static const double lg = 1240; // desktop
  static const double xl = 1440; // wide
}

extension MediaQueryResponsive on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  bool get isXs => screenWidth < AppBreakpoints.sm;
  bool get isSm => screenWidth >= AppBreakpoints.sm && screenWidth < AppBreakpoints.md;
  bool get isMd => screenWidth >= AppBreakpoints.md && screenWidth < AppBreakpoints.lg;
  bool get isLg => screenWidth >= AppBreakpoints.lg && screenWidth < AppBreakpoints.xl;
  bool get isXl => screenWidth >= AppBreakpoints.xl;
  bool get isDesktop => screenWidth >= AppBreakpoints.md;
}

/// Container que limita ancho máximo y aplica padding lateral adaptativo.
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Alignment alignment;
  const MaxWidthContainer({super.key, required this.child, this.maxWidth = 1200, this.alignment = Alignment.topCenter});

  EdgeInsets _horizontalPadding(double width) {
    if (width < AppBreakpoints.sm) return const EdgeInsets.symmetric(horizontal: 16);
    if (width < AppBreakpoints.md) return const EdgeInsets.symmetric(horizontal: 24);
    if (width < AppBreakpoints.lg) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 48);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = _horizontalPadding(width);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
