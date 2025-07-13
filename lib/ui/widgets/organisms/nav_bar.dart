
import 'package:flutter/material.dart';
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
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical:2, horizontal: 40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
              child: Icon(
                Icons.home_filled,
                color: currentRoute == '/'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(.5),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(context, '/favorites'),
              child: Icon(
                Icons.favorite,
                color: currentRoute == '/favorites'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(.5),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/settings', (route) => false),
              child: Icon(
                Icons.settings_outlined,
                color: currentRoute == '/settings'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
// ...fin del widget OwnNavBar...
}