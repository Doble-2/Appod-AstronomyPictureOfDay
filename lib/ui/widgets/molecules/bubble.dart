import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Burbuja glass translúcida (HIG — deferencia): el control se funde con el
/// contenido en vez de competir con él. BackdropFilter + superficie alfa +
/// borde hairline, sin elevación dura.
class Bubble extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const Bubble({super.key, required this.child, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? scheme.surface.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.35),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(7.0),
          child: child,
        ),
      ),
    );
  }
}
