import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/utils/image_proxy.dart';

class PrincipalApodButton extends StatefulWidget {
  final VoidCallback onTap;

  const PrincipalApodButton({
    super.key,
    required this.onTap,
  });

  @override
  State<PrincipalApodButton> createState() => _PrincipalApodState();
}

class _PrincipalApodState extends State<PrincipalApodButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        if (state.status == ApodStatus.loading) {
          return const SkeletonPrincipalApodButton();
        } else if (state.status == ApodStatus.success && state.apodData != null) {
          final isImage = state.apodData!["media_type"] == "image";
          final title = state.apodData!["title"] ?? '';
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth > 0 ? constraints.maxWidth : MediaQuery.of(context).size.width - 32;
                final isWide = constraints.maxWidth >= 900; // breakpoint simple
                final double targetHeight = isWide ? (width / (16 / 9)).clamp(260, 420) : 220;
                return MouseRegion(
                  onEnter: (_) => setState(() => _hover = true),
                  onExit: (_) => setState(() => _hover = false),
                  cursor: SystemMouseCursors.click,
                  child: Semantics(
                    label: 'Imagen destacada: $title',
                    button: true,
                    child: Tooltip(
                      message: title,
                      waitDuration: const Duration(milliseconds: 400),
                      child: AnimatedScale(
                        scale: _hover ? 1.01 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: targetHeight,
                          width: width,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            elevation: 0,
                            shadowColor: Theme.of(context).colorScheme.primary,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                context.read<ApodBloc>().add(
                                  ChangeDate(state.apodData!['date']),
                                );
                                widget.onTap();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Theme.of(context).colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: _hover ? 0.18 : 0.1),
                                      blurRadius: _hover ? 30 : 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: _hover && context.isDesktop
                                      ? Border.all(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                          width: 1.2,
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    AnimatedOpacity(
                                      opacity: 1.0,
                                      duration: const Duration(milliseconds: 500),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          image: isImage && (state.apodData!["url"]) != null
                                              ? DecorationImage(
                                                  image: NetworkImage(proxiedImageUrl(state.apodData!["url"])),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: isImage ? Colors.grey[200] : Theme.of(context).colorScheme.surface,
                                        ),
                                        child: !isImage
                                            ? Center(
                                                child: Icon(
                                                  Icons.play_circle_fill_rounded,
                                                  size: 64,
                                                  color: Theme.of(context).colorScheme.primary,
                                                  semanticLabel: 'Video',
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withValues(alpha: 0.1),
                                            Colors.black.withValues(alpha: 0.8),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 18,
                                      right: 18,
                                      bottom: 18,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state.apodData!["title"] ?? "",
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: const [
                                                    Shadow(
                                                      color: Colors.black,
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            state.apodData!["date"] ?? "",
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
            ),
            child: const Center(child: Text('No data available')),
          );
        }
      },
    );
  }
}
