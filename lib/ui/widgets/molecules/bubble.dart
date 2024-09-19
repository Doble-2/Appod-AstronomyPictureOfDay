import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final Widget child;

  const Bubble({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: child,
      ),
    );
  }
}
