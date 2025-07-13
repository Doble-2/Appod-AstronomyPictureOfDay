
import 'package:flutter/material.dart';

class SkeletonData extends StatelessWidget {
  const SkeletonData({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 40,
            width: 150,
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
          Container(
            height: 40,
            width: 150,
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
        ],
      ),
    );
  }
}
