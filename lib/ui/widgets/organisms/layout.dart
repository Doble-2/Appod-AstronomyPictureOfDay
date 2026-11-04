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
/// in use. Each tab is its own route, so the dock remembers where the capsule
/// was and slides it over from there when the next tab appears.
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
  static const _itemWidth = 86.0;
  static const _itemHeight = 56.0;
  static const _pad = 6.0;
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.45 : 0.16), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Glass(
        radius: AppTheme.radiusPill,
        child: Container(
          width: count * _itemWidth + 2 * _pad,
          height: _itemHeight + 2 * _pad,
          padding: const EdgeInsets.all(_pad),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: _from, end: widget.currentIndex.toDouble()),
            duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 320),
            curve: const Cubic(0.23, 1, 0.32, 1),
            builder: (context, at, _) => Stack(
              children: [
                Positioned(
                  left: at * _itemWidth,
                  top: 0,
                  width: _itemWidth,
                  height: _itemHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: dark ? 0.2 : 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final _NavItem item;
  final double lit;
  final bool selected;
  final double width;
  final double height;
  final VoidCallback onTap;
  const _DockItem({required this.item, required this.lit, required this.selected, required this.width, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color.lerp(scheme.onSurfaceVariant, scheme.primary, lit)!;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(scale: 1 + 0.08 * lit, child: Icon(lit > 0.5 ? item.selectedIcon : item.icon, color: color, size: 22)),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 11, fontWeight: lit > 0.5 ? FontWeight.w700 : FontWeight.w500, letterSpacing: 0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
