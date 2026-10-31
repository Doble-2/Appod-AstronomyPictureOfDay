import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';

/// App frame: text tabs across the top on large screens, a bottom bar on phones.
class Layout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Layout({super.key, required this.child, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    final items = <(String, IconData, IconData)>[
      (i10n.today, Icons.image_outlined, Icons.image_rounded),
      (i10n.favorites, Icons.favorite_border_rounded, Icons.favorite_rounded),
      (i10n.settings, Icons.tune_rounded, Icons.tune_rounded),
      if (kIsWeb) (i10n.getApp, Icons.download_outlined, Icons.download_rounded),
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isDesktop ? 64 : 52),
        child: SafeArea(
          bottom: false,
          child: _TopBar(items: items, currentIndex: currentIndex, onTap: onTap),
        ),
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 48), child: child),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              destinations: [
                for (final (label, icon, selected) in items)
                  NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: label),
              ],
            ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final List<(String, IconData, IconData)> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _TopBar({required this.items, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = context.isDesktop;
    return Container(
      height: isDesktop ? 64 : 52,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      child: Row(
        children: [
          Text('APPOD', style: TextStyle(fontFamily: 'Nasa', fontSize: isDesktop ? 24 : 20, color: theme.colorScheme.onSurface)),
          const Spacer(),
          if (isDesktop)
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _Tab(label: items[i].$1, selected: i == currentIndex, onTap: () => onTap(i)),
              ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          backgroundColor: selected ? scheme.surfaceContainerHighest : null,
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Text(label),
      ),
    );
  }
}
