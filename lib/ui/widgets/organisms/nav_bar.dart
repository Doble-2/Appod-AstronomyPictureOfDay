import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
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
    print(Get.currentRoute);
    return SafeArea(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(.3),
              spreadRadius:
                  Theme.of(context).colorScheme.surface == Colors.black
                      ? 5
                      : .5,
              blurRadius: 5,
              offset: const Offset(0, .2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.values[1],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (_isLogged) {
                  Get.offAllNamed('/favorites');
                } 
              },
              child: Icon(Icons.favorite_border,
                  color: Get.currentRoute == '/favorites'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.5)),
            ),
            GestureDetector(
              onTap: () {
                Get.offAllNamed("/");
              },
              child: Icon(Icons.home_filled,
                  color: Get.currentRoute == '/'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.5)),
            ),
            GestureDetector(
              onTap: () {
                Get.offAllNamed("/settings");
              },
              child: Icon(Icons.settings_outlined,
                  color: Get.currentRoute == '/settings'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.5)),
            )
          ],
        ),
      ),
    );
  }
}
