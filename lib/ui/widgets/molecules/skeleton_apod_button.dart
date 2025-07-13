import 'package:flutter/material.dart';

class SkeletonApodButton extends StatelessWidget {
  const SkeletonApodButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 200,
        height: 180,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black
                        : Colors.black,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surface,
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
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Placeholder para el texto
            Positioned(
              left: 16,
              bottom: 32,
              right: 16,
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 12,
              right: 80,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
