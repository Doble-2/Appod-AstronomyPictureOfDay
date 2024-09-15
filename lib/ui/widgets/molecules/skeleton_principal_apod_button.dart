import 'package:flutter/material.dart';

class SkeletonPrincipalApodButton extends StatefulWidget {
  const SkeletonPrincipalApodButton({super.key});

  @override
  _SkeletonPrincipalApodButtonState createState() =>
      _SkeletonPrincipalApodButtonState();
}

class _SkeletonPrincipalApodButtonState
    extends State<SkeletonPrincipalApodButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: const LinearGradient(
            colors: [Color(0xFF161616), Color(0xFF1A1A1A)],
            stops: [0.2, 2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
