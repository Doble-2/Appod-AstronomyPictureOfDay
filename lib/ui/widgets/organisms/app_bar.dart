import 'package:flutter/material.dart';

// Creating a StatelessWidget for a general button
class OwnAppBar extends StatelessWidget {
  const OwnAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'APPOD',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontFamily: 'Nasa',
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }
}
