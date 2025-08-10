import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/widgets/organisms/nav_bar.dart';

/// Navegación adaptativa: bottom nav (mobile) o rail lateral (desktop).
class AdaptiveNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AdaptiveNavigation({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) {
      return OwnNavBar(currentIndex: currentIndex, onTap: onTap);
    }
    return _SideRail(currentIndex: currentIndex, onTap: onTap);
  }
}

class _SideRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _SideRail({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Barra de navegación lateral',
      container: true,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.7),
          border: Border(
            right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _SideIcon(
              icon: Icons.home_filled,
              label: 'Inicio',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _SideIcon(
              icon: Icons.favorite,
              label: 'Favoritos',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _SideIcon(
              icon: Icons.settings,
              label: 'Ajustes',
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SideIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SideIcon({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  State<_SideIcon> createState() => _SideIconState();
}

class _SideIconState extends State<_SideIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.selected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (_) {},
      child: Tooltip(
        message: widget.label,
        waitDuration: const Duration(milliseconds: 400),
        child: Semantics(
          selected: widget.selected,
            button: true,
            label: widget.label,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              onHover: (h) => setState(() => _hover = h),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: _hover || widget.selected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Icon(widget.icon, color: color, size: 26),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.selected ? color : Colors.transparent,
                        boxShadow: widget.selected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
