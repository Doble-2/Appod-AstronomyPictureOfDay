import 'package:flutter/material.dart';

class SkeletonPrincipalApodButton extends StatefulWidget {
  const SkeletonPrincipalApodButton({super.key});

  @override
  _SkeletonPrincipalApodButtonState createState() =>
      _SkeletonPrincipalApodButtonState();
}

class _SkeletonPrincipalApodButtonState
    extends State<SkeletonPrincipalApodButton> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
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
                    )),
        ),
      ),
    ]);
  }
}
