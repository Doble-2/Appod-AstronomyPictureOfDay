import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/organisms/app_bar.dart';
import 'package:nasa_apod/ui/widgets/organisms/nav_bar.dart';

class Layout extends StatelessWidget {
  const Layout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: OwnAppBar(),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal con padding inferior para no ser tapado
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 40.0),
                  child: SingleChildScrollView(child: child),
                ),
              ),
            ),
            // NavBar flotante
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: 420,
                    child: OwnNavBar(),
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
