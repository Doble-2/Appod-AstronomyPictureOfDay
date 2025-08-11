import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:nasa_apod/ui/widgets/organisms/apod_collection.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';

class OtherApod extends StatelessWidget {
  final VoidCallback onTap;
  final bool embedded;

  const OtherApod({
    super.key,
    required this.onTap,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final content = AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeIn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleArea(text: i10n.otherApods),
          const SizedBox(height: 10),
          const ApodCollection(),
        ],
      ),
    );

    // Glassmorphism eliminado: usar contenedor plano opcional en desktop
    if (embedded && context.isDesktop) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20) ,
      child: content,
    );
  }
}

