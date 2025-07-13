import 'package:flutter/material.dart';

class SkeletonApodButton extends StatelessWidget {
  const SkeletonApodButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
