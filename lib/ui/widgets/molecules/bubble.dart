import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final Widget child;

  Bubble({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF3F7FE),
        borderRadius: BorderRadius.all(Radius.circular(100.0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(7.0),
        child: this.child,
      ),
    );
  }
}
