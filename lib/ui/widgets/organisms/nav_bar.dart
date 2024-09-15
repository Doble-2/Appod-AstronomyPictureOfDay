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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF161616), Color(0xFF1A1A1A)],
          stops: [0.5, 2],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        /*boxShadow: [
            BoxShadow(
                color: Color.fromARGB(255, 255, 0, 0).withOpacity(0.2),
                blurRadius: 70,
                offset: Offset(0, -10))
          ]*/
      ),
      child: Row(
          mainAxisSize: MainAxisSize.values[1],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.star_border,
              color: Colors.white,
            ),
            Icon(Icons.home, color: Colors.white, size: 35),
            Icon(
              Icons.settings_outlined,
              color: Colors.white,
            ),
          ]),
    ));
  }
}
