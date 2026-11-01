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

/// The picture currently in focus. It tints the whole screen behind the interface.
final ambientPicture = ValueNotifier<String?>(null);

/// Sets the ambient picture from a day of the archive; videos without a thumbnail clear it.
void setAmbientFrom(Map? apod) {
  final url = (apod?['url'] ?? '') as String;
  final isVideo = apod?['media_type'] == 'video';
  final resolved = apodImageUrl(url);
  if (url.isEmpty || (isVideo && resolved == proxiedImageUrl(url))) return;
  // A very small version is enough, since it is heavily blurred.
  ambientPicture.value = resolved.replaceFirst('w=1280', 'w=240');
}

/// The screen's backdrop: the picture in focus, blurred into pure color.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: scheme.surface),
          ValueListenableBuilder<String?>(
            valueListenable: ambientPicture,
            builder: (context, url, _) => AnimatedSwitcher(
              duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 900),
              child: url == null
                  ? const SizedBox.expand()
                  : ImageFiltered(
                      key: ValueKey(url),
                      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70, tileMode: TileMode.clamp),
                      child: Image.network(url, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => const SizedBox.expand()),
                    ),
            ),
          ),
          // A veil keeps text legible over any picture.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface.withValues(alpha: isDark ? 0.45 : 0.62),
                  scheme.surface.withValues(alpha: isDark ? 0.82 : 0.9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark glass with white content, for anything sitting on a photograph.
class PhotoGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  const PhotoGlass({super.key, required this.child, this.radius = 24, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: child,
        ),
      ),
    );
  }
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
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
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
  final double aspectRatio;
  final String? eyebrow;
  final VoidCallback? onRemove;
  final VoidCallback? onReturned;
  const ApodCard({super.key, required this.apod, this.aspectRatio = 4 / 5, this.eyebrow, this.onRemove, this.onReturned});

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
    final calm = reduceMotion(context);
    final apod = widget.apod;
    final date = (apod['date'] ?? '') as String;
    return AnimatedScale(
      scale: _pressed && !calm ? 0.97 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: _hover ? 0.42 : 0.24), blurRadius: _hover ? 28 : 18, offset: Offset(0, _hover ? 14 : 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest,
              child: InkWell(
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onHover: (value) => setState(() => _hover = value),
                onHighlightChanged: (value) => setState(() => _pressed = value),
                onTap: () async {
                  await Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.day(date));
                  setAmbientFrom(apod);
                  widget.onReturned?.call();
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: _hover && !calm ? 1.05 : 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      child: Hero(
                        tag: 'apod-$date',
                        flightShuttleBuilder: roundedFlight,
                        child: ApodImage(url: (apod['url'] ?? '') as String, isVideo: apod['media_type'] == 'video'),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.5, 1], colors: [Colors.transparent, Color(0xD0000000)]),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.eyebrow ?? longDate(date, Localizations.localeOf(context).languageCode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.78), fontSize: 11),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            (apod['title'] ?? '') as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: AppTheme.display, fontWeight: FontWeight.w600, fontSize: 15, height: 1.18, letterSpacing: -0.2, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onRemove != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GlassIconButton(icon: Icons.favorite_rounded, color: const Color(0xFFFF5A6E), tooltip: i10n.removeFromFavorites, onPressed: widget.onRemove!),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// A Pinterest-style wall: columns of pictures with varied heights.
class ApodMasonry<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item, double aspectRatio) builder;
  const ApodMasonry({super.key, required this.items, required this.builder});

  // Width over height. The repeating rhythm keeps both columns ending close together.
  static const _shapes = [0.8, 1.05, 1.1, 0.72, 0.9, 1.0];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 600 ? 3 : 2;
      const gap = 12.0;
      final columns = List.generate(count, (_) => <Widget>[]);
      final heights = List.filled(count, 0.0);
      for (var i = 0; i < items.length; i++) {
        final shape = _shapes[i % _shapes.length];
        var shortest = 0;
        for (var c = 1; c < count; c++) {
          if (heights[c] < heights[shortest] - 0.01) shortest = c;
        }
        heights[shortest] += 1 / shape;
        columns[shortest].add(Padding(
          padding: const EdgeInsets.only(bottom: gap),
          child: Reveal(index: i, child: builder(items[i], shape)),
        ));
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < count; c++) ...[
            if (c > 0) const SizedBox(width: gap),
            Expanded(child: Column(children: columns[c])),
          ],
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
