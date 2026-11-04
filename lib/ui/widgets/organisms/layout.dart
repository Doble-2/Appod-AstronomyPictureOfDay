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
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, 12))],
                    ),
                    child: Glass(
                      radius: AppTheme.radiusPill,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < items.length; i++)
                              _Tab(item: items[i], selected: i == currentIndex, labeled: i == currentIndex, onTap: () => onTap(i)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
