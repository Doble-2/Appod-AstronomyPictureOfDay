import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class GetAppWebPage extends StatelessWidget {
  const GetAppWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PageBody(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(i10n.getAppTitle, style: theme.textTheme.displaySmall),
          SectionGroup(
            title: i10n.getAppAndroidOnly,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i10n.getAppIntro, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text(i10n.getAppNotInPlay, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => ul.launchUrl(Uri.base.resolve('/appod.apk'), mode: ul.LaunchMode.platformDefault),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(i10n.getAppAction),
                    ),
                    Text('71 MB', style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
