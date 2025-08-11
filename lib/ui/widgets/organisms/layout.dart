import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/organisms/app_bar.dart';
import 'package:nasa_apod/ui/widgets/organisms/adaptive_navigation.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';


class Layout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final bool hideNavBar;
  const Layout({super.key, required this.child, required this.currentIndex, required this.onNavTap, this.hideNavBar = false});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final bodyContent = MaxWidthContainer(child: child);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: OwnAppBar(),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hideNavBar) AdaptiveNavigation(currentIndex: currentIndex, onTap: onNavTap),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 32, top: 32),
                      child: bodyContent,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(6 , 12, 6,12),
                      child: bodyContent,
                    ),
                  ),
                  if (!hideNavBar)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: SizedBox(
                          width: 420,
                          child: AdaptiveNavigation(
                            currentIndex: currentIndex,
                            onTap: onNavTap,
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
