import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:nasa_apod/provider/main_screen_controller.dart';

class OwnNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const OwnNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NavBarIcon(
                    icon: Icons.home_filled,
                    label: 'Inicio',
                    selected: currentIndex == 0,
                    onTap: () => Provider.of<MainScreenController>(context, listen: false)
                        .goTo(0, animation: MainScreenTransition.fade),
                  ),
                  _NavBarIcon(
                    icon: Icons.favorite,
                    label: 'Favoritos',
                    selected: currentIndex == 1,
                    onTap: () => Provider.of<MainScreenController>(context, listen: false)
                        .goTo(1, animation: MainScreenTransition.fade),
                  ),
                  _NavBarIcon(
                    icon: Icons.settings,
                    label: 'Ajustes',
                    selected: currentIndex == 2,
                    onTap: () => Provider.of<MainScreenController>(context, listen: false)
                        .goTo(2, animation: MainScreenTransition.fade),
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

class _NavBarIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavBarIcon> createState() => _NavBarIconState();
}

class _NavBarIconState extends State<_NavBarIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.18,
    );
    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _NavBarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !_controller.isCompleted) {
      _controller.forward();
    } else if (!widget.selected && !_controller.isDismissed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.label,
        waitDuration: const Duration(milliseconds: 400),
        child: Semantics(
          label: widget.label,
          button: true,
          selected: widget.selected,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = _controller.value * (_hover ? 1.08 : 1.0);
                return Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.selected)
                        Positioned.fill(
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastOutSlowIn,
                              width: 35 + (_hover ? 4 : 0),
                              height: 35 + (_hover ? 4 : 0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              ),
                            ),
                          ),
                        ),
                      Transform.scale(
                        scale: scale,
                        child: Icon(
                          widget.icon,
                          size: 24,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
// ...fin del widget OwnNavBar...
}
