import 'package:flutter/material.dart';

class SkeletonPrincipalApodButton extends StatefulWidget {
  const SkeletonPrincipalApodButton({super.key});

  @override
  State<SkeletonPrincipalApodButton> createState() =>
      _SkeletonPrincipalApodButtonState();
}

class _SkeletonPrincipalApodButtonState
    extends State<SkeletonPrincipalApodButton> {
  @override
  Widget build(BuildContext context) {
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
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                // Efecto shimmer animado
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: -1, end: 2),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return ShaderMask(
                        shaderCallback: (rect) {
              return LinearGradient(
              colors: [
                Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.8),
                Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.6),
                Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.4),
              ],
                            stops: const [0.1, 0.5, 0.9],
                            begin: const Alignment(-1, -1),
                            end: Alignment(value, 1),
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
