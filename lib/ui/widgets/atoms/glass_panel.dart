import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';

/// Panel estilo glassmorphism para desktop; en mobile simplifica capa para performance.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(28);

    final baseDecoration = BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.surface.withOpacity(0.12),
          theme.colorScheme.surfaceVariant.withOpacity(0.07),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        width: 1.2,
        color: Colors.white.withOpacity(0.08),
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.10),
          blurRadius: 32,
          spreadRadius: -12,
          offset: const Offset(0, 4),
        )
      ],
    );

    final panel = Container(
      padding: padding,
      decoration: baseDecoration,
      child: child,
    );

    if (!isDesktop) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: theme.colorScheme.surface.withOpacity(0.5),
        ),
        child: panel,
      );
    }

    return Container(
      margin: margin,
      decoration: const BoxDecoration(),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: panel,
        ),
      ),
    );
  }
}
