import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Creating a StatelessWidget for a general button
class OwnAppBar extends StatelessWidget {
  const OwnAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      //title: SvgPicture.asset('wormLogo.svg', height: 26, width: 30),
      title: Text(
        'APPOD',
        style: TextStyle(
          color: Color(0xFFE03C31),
          fontFamily: 'Nasa',
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
      centerTitle: true,
    );
  }
}
