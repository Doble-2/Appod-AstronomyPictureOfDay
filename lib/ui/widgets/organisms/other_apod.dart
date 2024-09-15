import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:nasa_apod/ui/widgets/organisms/apod_slider.dart';

class OtherApod extends StatelessWidget {
  final VoidCallback onTap;

  const OtherApod({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleArea(text: 'Other days'),
        Padding(padding: EdgeInsets.only(top: 10.0), child: ApodSlider()),
      ],
    );
  }
}
