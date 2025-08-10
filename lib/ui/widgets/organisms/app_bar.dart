import 'package:flutter/material.dart';

// Creating a StatelessWidget for a general button
class OwnAppBar extends StatelessWidget {
  const OwnAppBar({super.key});

  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context);

    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
        ),
      ),
      title: Text(
        'APPOD',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
