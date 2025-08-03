import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:nasa_apod/ui/widgets/organisms/apod_slider.dart';

class OtherApod extends StatelessWidget {
  final VoidCallback onTap;

  const OtherApod({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeIn,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleArea(text: i10n.otherApods),
            const SizedBox(height: 16),
            const ApodSlider(),
          ],
        ),
      ),
    );
  }
}
