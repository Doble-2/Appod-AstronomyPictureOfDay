import 'package:flutter/material.dart';

class SkeletonDescription extends StatelessWidget {
  const SkeletonDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 600,
        child: ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      gradient:
                          Theme.of(context).colorScheme.surface == Colors.black
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
                ));
          },
        ));
  }
}
