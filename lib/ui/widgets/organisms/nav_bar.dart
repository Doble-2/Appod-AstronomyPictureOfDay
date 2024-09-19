import 'package:flutter/material.dart';

// Creating a StatelessWidget for a general button
class OwnNavBar extends StatelessWidget {
  const OwnNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(.3),
              spreadRadius:
                  Theme.of(context).colorScheme.surface == Colors.black
                      ? 5
                      : .5,
              blurRadius: 5,
              offset: Offset(0, .2),
            )
          ]),
      child: Row(
          mainAxisSize: MainAxisSize.values[1],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.5)),
            Icon(Icons.home_outlined,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.5)),
            Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
            ),
          ]),
    ));
  }
}
