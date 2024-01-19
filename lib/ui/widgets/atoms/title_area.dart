import 'package:flutter/material.dart';

class TitleArea extends StatelessWidget {
  final String text;

  const TitleArea({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 25),
    );
  }
}
