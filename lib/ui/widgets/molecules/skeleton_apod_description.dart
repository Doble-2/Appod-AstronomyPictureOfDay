import 'package:flutter/material.dart';

class SkeletonDescription extends StatelessWidget {
  const SkeletonDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: List.generate(8, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          );
        }),
      ),
    );
  }
}
