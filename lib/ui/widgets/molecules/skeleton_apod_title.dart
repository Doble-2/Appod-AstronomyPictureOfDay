import 'package:flutter/material.dart';

class SkeletonTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: Theme.of(context).colorScheme.surface == Colors.black
                ? LinearGradient(
                    colors: [
                      Color.fromRGBO(107, 107, 107, 0.466),
                      Color.fromARGB(22, 126, 125, 125),
                    ],
                    stops: [0.2, 2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Color.fromRGBO(61, 61, 61, 0.322),
                      Color.fromARGB(22, 126, 125, 125),
                    ],
                    stops: [0.2, 2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
      ),
    );
  }
}
