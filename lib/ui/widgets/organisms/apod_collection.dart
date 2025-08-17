import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // PointerDeviceKind
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/widgets/molecules/apod_button.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_button.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';

/// Colección adaptativa de APODs: lista horizontal en mobile, grid en desktop.
class ApodCollection extends StatelessWidget {
  const ApodCollection({super.key});

  @override
  Widget build(BuildContext context) {
  final i10n = AppLocalizations.of(context)!;
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<ApodBloc, ApodState>(
    buildWhen: (p, c) =>
      p.multiplestatus != c.multiplestatus ||
      p.date != c.date ||
      p.multipleApodData.length != c.multipleApodData.length,
        builder: (context, state) {
          // Si estamos en desktop y hay menos de 10 elementos, pedir 10 (solo tras éxito inicial o cuando la lista esté vacía).
          if (context.isDesktop && (state.multipleApodData.length < 10) && state.multiplestatus != ApodStatus.loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<ApodBloc>().add(FetchMultipleApodSized(10));
              }
            });
          }
          if (state.multiplestatus == ApodStatus.success &&
              state.multipleApodData.isNotEmpty) {
            if (context.isDesktop) {
              return _DesktopHorizontalApodSlider(apods: state.multipleApodData);
            }
            return SizedBox(
              height: 210,
              child: ScrollConfiguration(
                behavior: _HorizontalDragBehavior(),
                child: ListView.separated(
                  padding: const EdgeInsets.only(right: 8),
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.multipleApodData.length,
                  itemBuilder: (context, index) {
                    // Botón de paginación eliminado
                    final apodData = state.multipleApodData[index];
                    if (apodData['url'] == null) {
                      return const SkeletonApodButton();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ApodButton(
                        image: apodData['url'],
                        title: apodData['title'],
                        date: apodData['date'],
                        author: apodData['copyright'] ?? 'Nasa',
                      ),
                    );
                  },
                ),
              ),
            );
          }
          if (state.multiplestatus != ApodStatus.failed) {
            if (context.isDesktop) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const SkeletonApodButton(),
              );
            }
            return SizedBox(
              height: 210,
              child: ScrollConfiguration(
                behavior: _HorizontalDragBehavior(),
                child: ListView.separated(
                  padding: const EdgeInsets.only(right: 8),
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => const SkeletonApodButton(),
                  itemCount: 7,
                ),
              ),
            );
          }
          final isNasaDown = state.errorCode == 504;
          return Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isNasaDown ? i10n.nasaDownTitle : i10n.genericError,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => context.read<ApodBloc>().add(FetchMultipleApod()),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(i10n.retry),
              ),
            ],
          );
        },
      );
    });
  }
}

class _HorizontalDragBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  // Quita glow/overscroll en Android y la scrollbar.
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // sin efecto glow
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // sin scrollbar
  }
}

class _DesktopHorizontalApodSlider extends StatefulWidget {
  final List apods;
  const _DesktopHorizontalApodSlider({required this.apods});

  @override
  State<_DesktopHorizontalApodSlider> createState() => _DesktopHorizontalApodSliderState();
}

class _DesktopHorizontalApodSliderState extends State<_DesktopHorizontalApodSlider> {
  final ScrollController _controller = ScrollController();

  void _scrollAmount(double delta) {
    final target = (_controller.offset + delta).clamp(0.0, _controller.position.maxScrollExtent);
    _controller.animateTo(target, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apods = widget.apods.where((a) => a['url'] != null).toList();
    if (apods.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: _HorizontalDragBehavior(),
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final apod = apods[index];
                return SizedBox(
                  width: 260,
                  child: ApodButton(
                    image: apod['url'],
                    title: apod['title'],
                    date: apod['date'],
                    author: apod['copyright'] ?? 'Nasa',
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemCount: apods.length,
            ),
          ),
          // Botón izquierda
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _EdgeFadeButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _scrollAmount(-320),
              alignment: Alignment.centerLeft,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _EdgeFadeButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _scrollAmount(320),
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _EdgeFadeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Alignment alignment;
  const _EdgeFadeButton({required this.icon, required this.onTap, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      ignoring: false,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: alignment == Alignment.centerLeft ? Alignment.centerLeft : Alignment.centerRight,
                end: alignment == Alignment.centerLeft ? Alignment.centerRight : Alignment.centerLeft,
                colors: [
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Align(
              alignment: alignment,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 26),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
