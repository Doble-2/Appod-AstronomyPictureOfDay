import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';

class SkeletonPrincipalApodButton extends StatefulWidget {
  @override
  _SkeletonPrincipalApodButtonState createState() =>
      _SkeletonPrincipalApodButtonState();
}

class _SkeletonPrincipalApodButtonState
    extends State<SkeletonPrincipalApodButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [Color(0xFF161616), Color(0xFF1A1A1A)],
            stops: [0.2, 2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
