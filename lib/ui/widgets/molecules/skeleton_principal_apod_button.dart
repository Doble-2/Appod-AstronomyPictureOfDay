import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_data.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_description.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_title.dart';

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
      ),
    ]);
  }
}
