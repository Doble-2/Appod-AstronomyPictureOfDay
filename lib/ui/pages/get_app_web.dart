import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';

class GetAppWebPage extends StatelessWidget {
  const GetAppWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    if (!kIsWeb) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TitleArea(text: i10n.getAppTitle),
        const SizedBox(height: 12),
        _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(i10n.getAppIntro, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(i10n.getAppNotInPlay, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.android_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(i10n.getAppAndroidOnly, style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 16),
              _ActionChip(text: i10n.getAppAction, icon: Icons.download_rounded),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _ActionChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
