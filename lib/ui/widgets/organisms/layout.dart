import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/widgets/common.dart';

/// App frame. On a page that opens with a photograph, the header sits clear
/// on the image and turns solid once the page scrolls past it.
class Layout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool immersive;

  const Layout({super.key, required this.child, required this.currentIndex, required this.onTap, this.immersive = false});

  static const headerHeight = 64.0;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  bool _pastPhoto = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final past = notification.metrics.pixels > MediaQuery.of(context).size.height * 0.5;
    if (past != _pastPhoto) setState(() => _pastPhoto = past);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    final padding = MediaQuery.of(context).padding;
    final scheme = Theme.of(context).colorScheme;
    final overPhoto = widget.immersive && !_pastPhoto;
    final items = <_NavItem>[
      _NavItem(i10n.today, Icons.home_outlined, Icons.home_rounded),
      _NavItem(i10n.favorites, Icons.favorite_border_rounded, Icons.favorite_rounded),
      _NavItem(i10n.settings, Icons.settings_outlined, Icons.settings_rounded),
      if (kIsWeb) _NavItem(i10n.getApp, Icons.download_outlined, Icons.download_rounded),
    ];
    final foreground = overPhoto ? Colors.white : scheme.onSurface;
    final header = SizedBox(
      height: Layout.headerHeight + padding.top,
      child: Padding(
        padding: EdgeInsets.fromLTRB(isDesktop ? 40 : 16, padding.top, isDesktop ? 28 : 16, 0),
        child: Row(
          children: [
            AppodLogo(color: overPhoto ? Colors.white : scheme.primary),
            const Spacer(),
            if (isDesktop)
              for (var i = 0; i < items.length; i++)
                _TopTab(label: items[i].label, selected: i == widget.currentIndex, color: foreground, onTap: () => widget.onTap(i)),
          ],
        ),
      ),
    );
    final lightIcons = overPhoto || scheme.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightIcons ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: widget.immersive ? 0 : padding.top + Layout.headerHeight,
                  bottom: padding.bottom + (isDesktop ? 64 : 104),
                ),
                child: widget.child,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: overPhoto
                  ? KeyedSubtree(key: const ValueKey('clear'), child: header)
                  : Glass(key: const ValueKey('solid'), radius: 0, bordered: _Edge.bottom, child: header),
            ),
          ),
          if (!isDesktop)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Glass(
                radius: 0,
                bordered: _Edge.top,
                child: Padding(
                  padding: EdgeInsets.only(bottom: padding.bottom),
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(child: _BottomTab(item: items[i], selected: i == widget.currentIndex, onTap: () => widget.onTap(i))),
                      ],
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

typedef _Edge = GlassEdge;

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

class _TopTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TopTab({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: color.withValues(alpha: selected ? 1 : 0.72),
              textStyle: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w500, fontSize: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(label),
          ),
          // The current tab is marked by more than its weight.
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: selected ? 18 : 0,
            height: 2,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
          ),
        ],
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _BottomTab({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(selected ? item.selectedIcon : item.icon, color: color, size: 24),
            ),
            const SizedBox(height: 3),
            Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
