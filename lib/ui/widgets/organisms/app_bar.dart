import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            bottom:
                BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'APPOD',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Nasa',
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                ),
          ),
          const SizedBox(width: 10),
          Semantics(
            label: 'Logo de APPOD',
            image: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: SvgPicture.asset(
                'assets/Appod.svg',
                height: 20,
                semanticsLabel: 'Logo APPOD',
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
    );
  }
}
