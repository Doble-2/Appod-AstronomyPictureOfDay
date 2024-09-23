import 'package:flutter/material.dart';

class SkeletonApodButton extends StatelessWidget {
  const SkeletonApodButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: Theme.of(context).colorScheme.surface == Colors.black
              ? const LinearGradient(
                  colors: [
                    Color.fromRGBO(107, 107, 107, 0.466),
                    Color.fromARGB(22, 126, 125, 125),
                  ],
                  stops: [0.2, 2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color.fromRGBO(61, 61, 61, 0.322),
                    Color.fromARGB(22, 126, 125, 125),
                  ],
                  stops: [0.2, 2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                )),
          ],
        ));
  }
}
