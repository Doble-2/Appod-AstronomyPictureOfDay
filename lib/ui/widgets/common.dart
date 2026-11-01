import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
import 'package:nasa_apod/utils/image_proxy.dart';
import 'package:shimmer/shimmer.dart';

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
  final Color? background;
  const ApodImage({super.key, required this.url, this.isVideo = false, this.fit = BoxFit.cover, this.background});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = apodImageUrl(url);
    final hasThumbnail = !isVideo || resolved != proxiedImageUrl(url);
    final placeholder = ColoredBox(color: background ?? scheme.surfaceContainerHighest);
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

/// Frosted surface for anything that floats over content.
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  const Glass({super.key, required this.child, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(color: scheme.surface.withValues(alpha: isDark ? 0.55 : 0.72)),
          child: child,
        ),
      ),
    );
  }
}

/// Round glass icon button for use over photographs.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
  const GlassIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          style: IconButton.styleFrom(backgroundColor: Colors.black38, minimumSize: const Size(48, 48)),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(icon, key: ValueKey(icon), color: color ?? Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Animated placeholder while a picture's data loads.
class Skeleton extends StatelessWidget {
  final double? height;
  final double radius;
  const Skeleton({super.key, this.height, this.radius = AppTheme.radius});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.outlineVariant,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

/// One day of the archive: a photograph with its title on it.
class ApodCard extends StatefulWidget {
  final Map apod;
  final VoidCallback? onRemove;
  final VoidCallback? onReturned;
  const ApodCard({super.key, required this.apod, this.onRemove, this.onReturned});

  @override
  State<ApodCard> createState() => _ApodCardState();
}

class _ApodCardState extends State<ApodCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apod = widget.apod;
    final date = (apod['date'] ?? '') as String;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest,
          child: InkWell(
            onHover: (value) => setState(() => _hover = value),
            onTap: () async {
              await Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.day(date));
              widget.onReturned?.call();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _hover ? 1.05 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Hero(tag: 'apod-$date', child: ApodImage(url: (apod['url'] ?? '') as String, isVideo: apod['media_type'] == 'video')),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.45, 1], colors: [Colors.transparent, Color(0xCC000000)]),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(longDate(date, Localizations.localeOf(context).languageCode), style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 2),
                      Text((apod['title'] ?? '') as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                if (widget.onRemove != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GlassIconButton(icon: Icons.favorite_rounded, tooltip: i10n.removeFromFavorites, onPressed: widget.onRemove!),
                  ),
              ],
            ),
          ),
        ),
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
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
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
