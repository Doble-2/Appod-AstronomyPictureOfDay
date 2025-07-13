import 'package:flutter/material.dart';

class SkeletonTitle extends StatelessWidget {
  const SkeletonTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
