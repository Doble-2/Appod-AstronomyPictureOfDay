import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/widgets/common.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: StateMessage(
        icon: Icons.explore_off_rounded,
        title: i10n.pageNotFound,
        body: i10n.pageNotFoundBody,
        actionLabel: i10n.backToToday,
        onAction: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      ),
    );
  }
}
