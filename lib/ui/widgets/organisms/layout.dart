import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/ui/widgets/common.dart';

/// App frame: content scrolls under a glass header and a floating glass navigation pill.
class Layout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;
  /// The page starts with a full-bleed photograph that runs under the header.
  final bool immersive;

  const Layout({super.key, required this.child, required this.currentIndex, required this.onTap, this.immersive = false});

  static const headerHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    final padding = MediaQuery.of(context).padding;
    final items = <_NavItem>[
      _NavItem(i10n.today, Icons.auto_awesome_outlined, Icons.auto_awesome_rounded),
      _NavItem(i10n.favorites, Icons.favorite_border_rounded, Icons.favorite_rounded),
      _NavItem(i10n.settings, Icons.settings_outlined, Icons.settings_rounded),
      if (kIsWeb) _NavItem(i10n.getApp, Icons.download_outlined, Icons.download_rounded),
    ];
    final nav = _NavPill(items: items, currentIndex: currentIndex, onTap: onTap, alwaysLabeled: isDesktop);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: immersive ? 0 : padding.top + headerHeight + 8,
                bottom: padding.bottom + (isDesktop ? 48 : 112),
              ),
              child: child,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Glass(
              radius: 0,
              child: Padding(
                padding: EdgeInsets.only(top: padding.top),
                child: SizedBox(
                  height: headerHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                    child: Row(
                      children: [
                        const AppodLogo(),
                        const Spacer(),
                        if (isDesktop) nav,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!isDesktop)
            Positioned(left: 0, right: 0, bottom: padding.bottom + 16, child: Center(child: Glass(radius: 32, child: Padding(padding: const EdgeInsets.all(6), child: nav)))),
        ],
      ),
    );
  }
}

/// The logo next to the Nasa wordmark.
class AppodLogo extends StatelessWidget {
  const AppodLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('APPOD', style: TextStyle(fontFamily: 'Nasa', fontSize: 26, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: SvgPicture.asset('assets/Appod.svg', height: 18, semanticsLabel: 'APPOD'),
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

class _NavPill extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool alwaysLabeled;
  const _NavPill({required this.items, required this.currentIndex, required this.onTap, required this.alwaysLabeled});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          Builder(builder: (context) {
            final selected = i == currentIndex;
            final item = items[i];
            final color = selected ? AppTheme.onBrand : scheme.onSurface;
            return Semantics(
              button: true,
              selected: selected,
              label: item.label,
              excludeSemantics: true,
              child: Tooltip(
                message: item.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: selected ? AppTheme.brandGradient : null),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(selected ? item.selectedIcon : item.icon, color: color, size: 22),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: selected || alwaysLabeled
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
              ),
            );
          }),
      ],
    );
  }
}
