import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
import 'package:nasa_apod/utils/image_proxy.dart';

/// Page column: the same width and side margins on every screen.
class PageBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const PageBody({super.key, required this.child, this.maxWidth = 1240});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? 32 : 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A picture from the archive. Videos show their thumbnail, or a play mark.
class ApodImage extends StatelessWidget {
  final String url;
  final bool isVideo;
  final BoxFit fit;
  const ApodImage({super.key, required this.url, this.isVideo = false, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = apodImageUrl(url);
    final hasThumbnail = !isVideo || resolved != proxiedImageUrl(url);
    final placeholder = ColoredBox(color: scheme.surfaceContainer);
    return Stack(
      fit: StackFit.expand,
      children: [
        placeholder,
        if (hasThumbnail)
          Image.network(
            resolved,
            fit: fit,
            frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
              opacity: sync || frame != null ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: child,
            ),
            errorBuilder: (context, error, stack) => Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
          ),
        if (isVideo)
          const Center(child: Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 48, shadows: [Shadow(blurRadius: 12)])),
      ],
    );
  }
}

/// One day of the archive in a grid: picture, title, date.
class ApodCard extends StatelessWidget {
  final Map apod;
  final VoidCallback? onRemove;
  final VoidCallback? onReturned;
  const ApodCard({super.key, required this.apod, this.onRemove, this.onReturned});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = (apod['date'] ?? '') as String;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () async {
        await Navigator.of(context, rootNavigator: true).pushNamed('/apod/$date');
        onReturned?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ApodImage(url: (apod['url'] ?? '') as String, isVideo: apod['media_type'] == 'video'),
                  if (onRemove != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        tooltip: i10n.removeFromFavorites,
                        onPressed: onRemove,
                        style: IconButton.styleFrom(backgroundColor: Colors.black54),
                        icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text((apod['title'] ?? '') as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(longDate(date, Localizations.localeOf(context).languageCode), style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Grid of archive days, sized to the screen.
class ApodGrid extends StatelessWidget {
  final List<Widget> children;
  const ApodGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 600 ? 3 : 2;
      const gap = 20.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: 16,
        children: [for (final child in children) SizedBox(width: width, child: child)],
      );
    });
  }
}

/// Empty and error states: what happened, and what to do next.
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const StateMessage({super.key, required this.icon, required this.title, this.body, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
              if (body != null) ...[
                const SizedBox(height: 8),
                Text(body!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              ],
              if (onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel ?? '')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// NASA failures in the reader's language, instead of raw API text.
String apodErrorText(AppLocalizations i10n, int? code) => switch (code) {
      400 => i10n.errorBadDate,
      401 || 403 => i10n.errorKey,
      404 => i10n.errorNotFound,
      429 => i10n.errorRateLimit,
      500 || 502 || 503 => i10n.errorNasa,
      504 => i10n.errorTimeout,
      _ => i10n.errorConnection,
    };
