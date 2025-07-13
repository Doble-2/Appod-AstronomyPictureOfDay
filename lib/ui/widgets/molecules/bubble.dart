import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final Widget child;

  const Bubble({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: child,
      ),
    );
  }
}
