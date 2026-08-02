import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/organisms/app_bar.dart';
import 'package:nasa_apod/ui/widgets/organisms/adaptive_navigation.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';


class Layout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hideNavBar;

  const Layout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
    this.hideNavBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyContent = MaxWidthContainer(child: child);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: OwnAppBar(),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        // Fondo cinematográfico en gradiente: profundidad cósmica en dark, suave en light
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF070A14), // arriba: azul-noche
                    Color(0xFF05060A), // medio: casi negro
                    Color(0xFF0B0818), // abajo: halo violeta sutil
                  ]
                : const [
                    Color(0xFFF6F8FC),
                    Color(0xFFF6F8FC),
                    Color(0xFFF0F3FA),
                  ],
          ),
        ),
        child: SafeArea(
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hideNavBar)
                      AdaptiveNavigation(
                          currentIndex: currentIndex,
                          onTap: onTap),
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
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
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
                              onTap: onTap,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
