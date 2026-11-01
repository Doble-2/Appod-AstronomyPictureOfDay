import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';

double contrast(Color a, Color b) {
  final hi = max(a.computeLuminance(), b.computeLuminance());
  final lo = min(a.computeLuminance(), b.computeLuminance());
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, theme) in [('dark', AppTheme.dark), ('light', AppTheme.light)]) {
    final s = theme.colorScheme;
    test('$name theme text meets WCAG AA', () {
      expect(contrast(s.onSurface, s.surface), greaterThanOrEqualTo(4.5));
      expect(contrast(s.onSurfaceVariant, s.surface), greaterThanOrEqualTo(4.5));
      expect(contrast(s.primary, s.surface), greaterThanOrEqualTo(4.5));
      expect(contrast(s.onPrimary, s.primary), greaterThanOrEqualTo(4.5));
      expect(contrast(s.onSurfaceVariant, s.surfaceContainer), greaterThanOrEqualTo(4.5));
    });
  }
}
