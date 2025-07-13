import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:nasa_apod/data/firebase.dart';

class OwnNavBar extends StatefulWidget {
  const OwnNavBar({super.key});

  @override
  _OwnNavBarState createState() => _OwnNavBarState();
}

class _OwnNavBarState extends State<OwnNavBar> {
  bool _isLogged = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    _isLogged = await AuthService().isLoggedIn();
    setState(() {
      _isLogged = _isLogged;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            color: Theme.of(context).colorScheme.surface,
            boxShadow:  [
              BoxShadow(
                color: Colors.black.withValues(alpha : 0.1),
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
                    selected: currentRoute == '/',
                    indicator: true,
                    onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                  ),
                  _NavBarIcon(
                    icon: Icons.favorite,
                    selected: currentRoute == '/favorites',
                    indicator: true,
                    onTap: () => Navigator.pushNamed(context, '/favorites'),
                  ),
                  _NavBarIcon(
                    icon: Icons.settings,
                    selected: currentRoute == '/settings',
                    indicator: true,
                    onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/settings', (route) => false),
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
  final bool selected;
  final VoidCallback onTap;
  final bool indicator;
  const _NavBarIcon({required this.icon, required this.selected, required this.onTap, this.indicator = false});

  @override
  State<_NavBarIcon> createState() => _NavBarIconState();
}

class _NavBarIconState extends State<_NavBarIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
        : Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.indicator && widget.selected)
                  Positioned.fill(
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn,
                        width: 35,
                        height: 35,
                      ),
                    ),
                  ),
                ScaleTransition(
                  scale: _controller,
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
    );
  }
// ...fin del widget OwnNavBar...
}