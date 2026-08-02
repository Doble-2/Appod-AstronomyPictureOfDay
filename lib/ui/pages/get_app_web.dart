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
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Future<void> download() async {
      final uri = Uri.base.resolve('appod.apk');
      await ul.launchUrl(uri, mode: ul.LaunchMode.platformDefault);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TitleArea(
              text: i10n.getAppTitle,
              subtitle: 'Disponible para Android',
            ),
            const SizedBox(height: 24),

            // Card principal: info + descarga
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.surface.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: isWide
                  ? Row(
                      children: [
                        // Lado texto
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i10n.getAppIntro,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  i10n.getAppNotInPlay,
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.65),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Chip plataforma
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: scheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: scheme.primary
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.android_rounded,
                                          size: 18,
                                          color: scheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        i10n.getAppAndroidOnly,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 220,
                                  child: FilledButton.icon(
                                    onPressed: download,
                                    icon:
                                        const Icon(Icons.download_rounded),
                                    label: const Text('Descargar APK'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Lado descarga destacado
                        Expanded(
                          flex: 4,
                          child: _DownloadCard(
                            onDownload: download,
                            fileSize: _formatBytes(71 * 1024 * 1024),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          i10n.getAppIntro,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          i10n.getAppNotInPlay,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.65),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.android_rounded,
                                size: 18, color: scheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              i10n.getAppAndroidOnly,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _DownloadCard(
                          onDownload: download,
                          fileSize: _formatBytes(71 * 1024 * 1024),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }
}

String _formatBytes(int bytes) {
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(0)} MB';
}

class _DownloadCard extends StatelessWidget {
  final VoidCallback onDownload;
  final String fileSize;
  const _DownloadCard({required this.onDownload, required this.fileSize});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gradient = LinearGradient(
      colors: [
        scheme.primary.withValues(alpha: 0.14),
        scheme.secondary.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: scheme.primary.withValues(alpha: 0.18), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de la app con glow sutil
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/icon/appod.png',
                height: 92,
                width: 92,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Appod',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.2 · $fileSize',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Descargar APK'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
