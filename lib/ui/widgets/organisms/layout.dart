import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/widgets/common.dart';

/// App frame: content over the ambient color of the current picture, with a
/// floating dock for navigation.
class Layout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Layout({super.key, required this.child, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    final padding = MediaQuery.of(context).padding;
    final scheme = Theme.of(context).colorScheme;
    final items = <_NavItem>[
      _NavItem(i10n.today, Icons.auto_awesome_outlined, Icons.auto_awesome_rounded),
      _NavItem(i10n.favorites, Icons.favorite_border_rounded, Icons.favorite_rounded),
      _NavItem(i10n.settings, Icons.tune_rounded, Icons.tune_rounded),
      if (kIsWeb) _NavItem(i10n.getApp, Icons.download_outlined, Icons.download_rounded),
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: scheme.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: AppBackground()),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: padding.top + (isDesktop ? 92 : 14), bottom: padding.bottom + (isDesktop ? 56 : 112)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDesktop)
                      const Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 14), child: AppodLogo()),
                    child,
                  ],
                ),
              ),
            ),
            if (isDesktop)
              Positioned(
                top: padding.top + 16,
                left: 0,
                right: 0,
                child: Center(
                  child: _Dock(
                    leading: const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: AppodLogo()),
                    items: items,
                    currentIndex: currentIndex,
                    onTap: onTap,
                    labeled: true,
                  ),
                ),
              )
            else
              Positioned(
                left: 0,
                right: 0,
                bottom: padding.bottom + 18,
                child: Center(child: _Dock(items: items, currentIndex: currentIndex, onTap: onTap, labeled: false)),
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

class _Dock extends StatelessWidget {
  final Widget? leading;
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool labeled;
  const _Dock({this.leading, required this.items, required this.currentIndex, required this.onTap, required this.labeled});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Glass(
        radius: 40,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) leading!,
              for (var i = 0; i < items.length; i++)
                Builder(builder: (context) {
                  final selected = i == currentIndex;
                  final item = items[i];
                  final color = selected ? scheme.onPrimary : scheme.onSurface;
                  return Tooltip(
                    message: item.label,
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: item.label,
                      excludeSemantics: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          height: 50,
                          constraints: const BoxConstraints(minWidth: 58),
                          padding: EdgeInsets.symmetric(horizontal: labeled ? 16 : 0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: selected ? scheme.primary : Colors.transparent),
                          child: labeled
                              ? Center(widthFactor: 1, child: Text(item.label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)))
                              : AnimatedScale(
                                  scale: selected ? 1.08 : 1,
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutBack,
                                  child: Icon(selected ? item.selectedIcon : item.icon, color: color, size: 24),
                                ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
