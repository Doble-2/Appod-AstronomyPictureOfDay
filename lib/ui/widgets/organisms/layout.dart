import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/ui/widgets/common.dart';

/// App frame: a glass header on large screens, a floating dock on phones.
class Layout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;
  /// False when the page scrolls itself, to build long lists lazily.
  final bool scrollable;

  const Layout({super.key, required this.child, required this.currentIndex, required this.onTap, this.scrollable = true});

  static const _headerHeight = 68.0;

  /// Space a page must leave clear at the top and bottom.
  static double topInset(BuildContext context) => MediaQuery.of(context).padding.top + (context.isDesktop ? _headerHeight + 28 : 14);
  static double bottomInset(BuildContext context) => MediaQuery.of(context).padding.bottom + (context.isDesktop ? 56 : 112);

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    final padding = MediaQuery.of(context).padding;
    final scheme = Theme.of(context).colorScheme;
    final items = <_NavItem>[
      _NavItem(i10n.today, Icons.nights_stay_outlined, Icons.nights_stay_rounded),
      _NavItem(i10n.favorites, Icons.favorite_border_rounded, Icons.favorite_rounded),
      _NavItem(i10n.settings, Icons.settings_outlined, Icons.settings_rounded),
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: scheme.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: AppBackground()),
            Positioned.fill(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: EdgeInsets.only(top: topInset(context), bottom: bottomInset(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isDesktop) const PageBody(child: Padding(padding: EdgeInsets.only(bottom: 14), child: AppodLogo())),
                          child,
                        ],
                      ),
                    )
                  : child,
            ),
            if (isDesktop)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Glass(
                  radius: 0,
                  bordered: GlassEdge.bottom,
                  child: Padding(
                    padding: EdgeInsets.only(top: padding.top),
                    child: SizedBox(
                      height: _headerHeight,
                      child: PageBody(
                        child: SizedBox(
                          height: _headerHeight,
                          child: Row(
                            children: [
                              const AppodLogo(),
                              const Spacer(),
                              for (var i = 0; i < items.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: _Tab(item: items[i], selected: i == currentIndex, labeled: true, onTap: () => onTap(i)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                left: 0,
                right: 0,
                bottom: padding.bottom + 18,
                child: Center(child: _Dock(items: items, currentIndex: currentIndex, onTap: onTap)),
              ),
          ],
        ),
      ),
    );
  }
}

/// The logo next to the Nasa wordmark.
class AppodLogo extends StatelessWidget {
  final Color? color;
  const AppodLogo({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('APPOD', style: TextStyle(fontFamily: 'Nasa', fontSize: 24, color: tint)),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: SvgPicture.asset('assets/Appod.svg', height: 17, semanticsLabel: 'APPOD', colorFilter: ColorFilter.mode(tint, BlendMode.srcIn)),
        ),
      ],
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _NavItem(this.label, this.icon, this.selectedIcon);
}

class _Tab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final bool labeled;
  final VoidCallback onTap;
  const _Tab({required this.item, required this.selected, required this.labeled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.onPrimary : scheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 48,
          constraints: const BoxConstraints(minWidth: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppTheme.radiusPill), color: selected ? scheme.primary : Colors.transparent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? item.selectedIcon : item.icon, color: color, size: 22),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: labeled
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(item.label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The phone dock: every tab named, and a lit capsule that glides to the one
/// in use, stretching a little in flight like a drop of liquid. Each tab is its
/// own route, so the dock remembers where the capsule was and slides it over
/// from there when the next tab appears.
class _Dock extends StatefulWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _Dock({required this.items, required this.currentIndex, required this.onTap});

  @override
  State<_Dock> createState() => _DockState();
}

class _DockState extends State<_Dock> {
  static int _shown = 0;
  static const _itemWidth = 82.0;
  static const _itemHeight = 54.0;
  static const _pad = 5.0;
  late final double _from;

  @override
  void initState() {
    super.initState();
    _from = _shown.toDouble();
    _shown = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final count = widget.items.length;
    final radius = BorderRadius.circular(AppTheme.radiusPill);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // A tight contact shadow and a wide soft one, like a real object.
          BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.35 : 0.10), blurRadius: 6, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.40 : 0.14), blurRadius: 36, offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: CustomPaint(
            foregroundPainter: _RimPainter(dark: dark),
            child: Container(
              width: count * _itemWidth + 2 * _pad,
              height: _itemHeight + 2 * _pad,
              padding: const EdgeInsets.all(_pad),
              color: dark ? const Color(0xFF1B1F27).withValues(alpha: 0.62) : Colors.white.withValues(alpha: 0.70),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: _from, end: widget.currentIndex.toDouble()),
                duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 420),
                curve: const Cubic(0.23, 1, 0.32, 1),
                builder: (context, at, _) {
                  // How far through the move: 0 at rest, 1 halfway.
                  final travel = (_from - widget.currentIndex).abs() < 0.01 ? 0.0 : sin(pi * ((at - _from) / (widget.currentIndex - _from)).clamp(0.0, 1.0));
                  final stretch = 16 * travel;
                  return Stack(
                    children: [
                      Positioned(
                        left: at * _itemWidth - stretch / 2,
                        top: 2 * travel,
                        width: _itemWidth + stretch,
                        height: _itemHeight - 4 * travel,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            color: dark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.055),
                            border: Border.all(color: (dark ? Colors.white : Colors.black).withValues(alpha: dark ? 0.10 : 0.05)),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < count; i++)
                            _DockItem(
                              item: widget.items[i],
                              // 1 under the capsule, fading to 0 a tab away.
                              lit: (1 - (at - i).abs()).clamp(0.0, 1.0),
                              selected: i == widget.currentIndex,
                              width: _itemWidth,
                              height: _itemHeight,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onTap(i);
                              },
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A hairline rim, bright along the top where light would catch the glass and
/// fading toward the bottom.
class _RimPainter extends CustomPainter {
  final bool dark;
  const _RimPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(size.height / 2));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.04)]
            : [Colors.white, Colors.black.withValues(alpha: 0.08)],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RimPainter old) => old.dark != dark;
}

class _DockItem extends StatefulWidget {
  final _NavItem item;
  final double lit;
  final bool selected;
  final double width;
  final double height;
  final VoidCallback onTap;
  const _DockItem({required this.item, required this.lit, required this.selected, required this.width, required this.height, required this.onTap});

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  bool _pressed = false;

  void _press(bool down) {
    if (_pressed != down) setState(() => _pressed = down);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lit = widget.lit;
    final color = Color.lerp(scheme.onSurface.withValues(alpha: 0.62), scheme.primary, lit)!;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.item.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _press(true),
          onTapCancel: () => _press(false),
          onTapUp: (_) => _press(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            // Feedback on press-in, not on release.
            scale: _pressed ? 0.9 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(lit > 0.5 ? widget.item.selectedIcon : widget.item.icon, color: color, size: 23),
                  const SizedBox(height: 2),
                  Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 10.5, fontWeight: lit > 0.5 ? FontWeight.w700 : FontWeight.w500, letterSpacing: 0.15, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
