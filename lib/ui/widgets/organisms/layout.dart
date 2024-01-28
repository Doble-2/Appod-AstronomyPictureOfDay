import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/organisms/app_bar.dart';
import 'package:nasa_apod/ui/widgets/organisms/nav_bar.dart';

class Layout extends StatelessWidget {
  const Layout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: const OwnAppBar(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(child: child),
      ),
      bottomNavigationBar: OwnNavBar(),
    );
  }
}
