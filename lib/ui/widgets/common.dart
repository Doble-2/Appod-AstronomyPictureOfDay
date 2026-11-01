import 'dart:math';
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
              duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 350),
              curve: Curves.easeOut,
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

/// Whether the reader asked for less motion in their system settings.
bool reduceMotion(BuildContext context) => MediaQuery.of(context).disableAnimations;

/// A faint field of stars behind the dark interface. Fixed, so it never distracts.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Stars only exist at night: on a light page they would read as dust.
    if (scheme.brightness == Brightness.light) return const SizedBox.expand();
    return RepaintBoundary(
      child: CustomPaint(painter: _StarsPainter(scheme.onSurface, 0.2), size: Size.infinite),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final Color color;
  final double strength;
  _StarsPainter(this.color, this.strength);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(1995); // The year APOD began, and the same sky every time.
    final paint = Paint();
    final stars = (size.width * size.height / 7000).round().clamp(40, 400);
    for (var i = 0; i < stars; i++) {
      final brightness = pow(random.nextDouble(), 3).toDouble();
      paint.color = color.withValues(alpha: (0.15 + brightness * 0.85) * strength);
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), 0.4 + brightness * 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.color != color || old.strength != strength;
}

/// Fades and rises into place, a little later for each [index] in a list.
class Reveal extends StatelessWidget {
  final int index;
  final Widget child;
  const Reveal({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    const base = 420;
    final delay = 45 * index.clamp(0, 8);
    final total = base + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, (1 - value) * 14), child: child),
      ),
    );
  }
}

/// A photograph's corners stay rounded while it flies to its page, then square off.
Widget roundedFlight(BuildContext flightContext, Animation<double> animation, HeroFlightDirection direction, BuildContext from, BuildContext to) {
  final hero = (direction == HeroFlightDirection.push ? from : to).widget as Hero;
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) => ClipRRect(borderRadius: BorderRadius.circular((1 - animation.value) * AppTheme.radius), child: child),
    child: hero.child,
  );
}

enum GlassEdge { none, top, bottom }

/// Frosted surface for bars that float over content.
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final GlassEdge bordered;
  const Glass({super.key, required this.child, this.radius = 24, this.bordered = GlassEdge.none});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final line = BorderSide(color: scheme.outlineVariant);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.88),
            border: Border(
              top: bordered == GlassEdge.top ? line : BorderSide.none,
              bottom: bordered == GlassEdge.bottom ? line : BorderSide.none,
            ),
          ),
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
            duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final calm = reduceMotion(context);
    final apod = widget.apod;
    final date = (apod['date'] ?? '') as String;
    return AnimatedScale(
      scale: _pressed && !calm ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        onHover: (value) => setState(() => _hover = value),
        onHighlightChanged: (value) => setState(() => _pressed = value),
        onTap: () async {
          await Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.day(date));
          widget.onReturned?.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? (_hover ? 0.5 : 0.3) : (_hover ? 0.18 : 0.08)),
                      blurRadius: _hover ? 24 : 14,
                      offset: Offset(0, _hover ? 10 : 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hover && !calm ? 1.04 : 1,
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        child: Hero(
                          tag: 'apod-$date',
                          flightShuttleBuilder: roundedFlight,
                          child: ApodImage(url: (apod['url'] ?? '') as String, isVideo: apod['media_type'] == 'video'),
                        ),
                      ),
                      // A hairline keeps dark pictures from melting into the background.
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radius),
                            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                          ),
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
            const SizedBox(height: 10),
            // Two lines are always reserved, so every card in a row ends level.
            SizedBox(
              height: 38,
              child: Text((apod['title'] ?? '') as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 2),
            Text(longDate(date, Localizations.localeOf(context).languageCode), style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// Grouped block for settings and similar content.
class SectionGroup extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionGroup({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: child,
          ),
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
        runSpacing: 28,
        children: [
          for (var i = 0; i < children.length; i++)
            Reveal(key: children[i].key, index: i, child: SizedBox(width: width, child: children[i])),
        ],
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.surfaceContainerHighest),
                child: Icon(icon, size: 28, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
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
