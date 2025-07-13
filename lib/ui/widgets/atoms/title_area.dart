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
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        fontFamily: 'Nasa',
        fontSize: 25,
      ),
    );
  }
}
