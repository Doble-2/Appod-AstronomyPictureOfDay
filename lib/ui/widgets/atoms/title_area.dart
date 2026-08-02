import 'package:flutter/material.dart';

/// Encabezado de sección con jerarquía limpia estilo Apple:
/// título grande + subtítulo opcional, con aire generoso.
class TitleArea extends StatelessWidget {
  final String text;
  final String? subtitle;

  const TitleArea({
    super.key,
    required this.text,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            height: 1.1,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
