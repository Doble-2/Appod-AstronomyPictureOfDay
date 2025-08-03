import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:provider/provider.dart';
import 'package:nasa_apod/provider/main_screen_controller.dart';

class ApodButton extends StatefulWidget {
  final String title;
  final String date;
  final String author;
  final String image;
  final VoidCallback? onRemove;
  final bool showRemoveButton;

  const ApodButton({
    super.key,
    required this.title,
    required this.date,
    required this.author,
    required this.image,
    this.onRemove,
    this.showRemoveButton = false,
  });

  @override
  State<ApodButton> createState() => _ApodButtonState();
}

class _ApodButtonState extends State<ApodButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, scale, child) {
          return AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              elevation: 0,
              shadowColor: isDark ? Colors.black : Colors.grey,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                splashColor: Theme.of(context).colorScheme.primary,
                highlightColor: Theme.of(context).colorScheme.primary,
                onTap: () async {
                  if (widget.showRemoveButton && _isExpanded) {
                    setState(() => _isExpanded = false);
                    return;
                  }
                  context.read<ApodBloc>().add(ChangeDate(widget.date));
              
                                          Navigator.pushNamed(context, '/appod');

                },
                
                onLongPress: widget.showRemoveButton
                    ? () => setState(() => _isExpanded = !_isExpanded)
                    : null,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Imagen de fondo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          widget.image,
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                  child: Icon(Icons.error_outline,
                                      color: Colors.red)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                      // Degradado para legibilidad
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(24)),
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
                      ),
                      // Textos superpuestos abajo
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.date,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Botón para eliminar (opcional)
                      if (widget.showRemoveButton)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isExpanded ? 1.0 : 0.0,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: _isExpanded ? 1.0 : 0.0,
                              child: GestureDetector(
                                onTap: widget.onRemove,
                                child: Bubble(
                                  child: Icon(
                                    Icons.delete_forever_rounded,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
