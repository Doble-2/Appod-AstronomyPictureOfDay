import 'package:flutter/material.dart';

class SkeletonTitle extends StatelessWidget {
  const SkeletonTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  ]
                : [
                    Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.15),
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  ],
            stops: const [0.2, 2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
