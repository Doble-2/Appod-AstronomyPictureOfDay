import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class GetAppWebPage extends StatelessWidget {
  const GetAppWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    if (!kIsWeb) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          TitleArea(text: i10n.getAppTitle),
          const SizedBox(height: 12),
          _InfoCard(
            child: isWide
                ? Row(
                    children: [
                      // Lado texto
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(i10n.getAppIntro, style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text(i10n.getAppNotInPlay, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.android_rounded, size: 16),
                                  const SizedBox(width: 6),
                                  Text(i10n.getAppAndroidOnly, style: theme.textTheme.bodyMedium),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _ActionChip(
                                text: i10n.getAppAction,
                                icon: Icons.download_rounded,
                                onTap: () async {
                                  final uri = Uri.base.resolve('appod.apk');
                                  await ul.launchUrl(uri, mode: ul.LaunchMode.platformDefault);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Lado descarga destacado
                      Expanded(
                        flex: 5,
                        child: _DownloadCard(
                          onDownload: () async {
                            final uri = Uri.base.resolve('appod.apk');
                            await ul.launchUrl(uri, mode: ul.LaunchMode.platformDefault);
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i10n.getAppIntro, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(i10n.getAppNotInPlay, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.android_rounded, size: 16),
                          const SizedBox(width: 6),
                          Text(i10n.getAppAndroidOnly, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DownloadCard(
                        onDownload: () async {
                          final uri = Uri.base.resolve('appod.apk');
                          await ul.launchUrl(uri, mode: ul.LaunchMode.platformDefault);
                        },
                      ),
                    ],
                  ),
          ),
        ],
      );
    });
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
  final VoidCallback? onTap;
  const _ActionChip({required this.text, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.primary;
    final bg = theme.colorScheme.primary.withValues(alpha: 0.08);
    final bd = theme.colorScheme.primary.withValues(alpha: 0.25);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: bd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  final VoidCallback onDownload;
  const _DownloadCard({required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = LinearGradient(
      colors: [
        theme.colorScheme.primary.withValues(alpha: 0.12),
        theme.colorScheme.secondary.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          // Icono de la app
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/icon/appod.png',
              height: 96,
              width: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Descargar APK'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'appod.apk',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
