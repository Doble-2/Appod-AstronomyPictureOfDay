import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonPrincipalApodButton extends StatelessWidget {
  const SkeletonPrincipalApodButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width - 32;
          return SizedBox(
            height: 220,
            width: width,
            child: Shimmer.fromColors(
              baseColor: scheme.surface,
              highlightColor: scheme.onSurface.withValues(alpha: 0.06),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  color: scheme.surface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
