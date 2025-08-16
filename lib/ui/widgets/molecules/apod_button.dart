import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/utils/image_proxy.dart';

class ApodButton extends StatefulWidget {
  final String title;
  final String date;
  final String author;
  final String image;
  final VoidCallback? onRemove;
  final bool showRemoveButton;
  final bool expand;

  const ApodButton({
    super.key,
    required this.title,
    required this.date,
    required this.author,
    required this.image,
    this.onRemove,
    this.showRemoveButton = false,
    this.expand = false,
  });

  @override
  State<ApodButton> createState() => _ApodButtonState();
}

class _ApodButtonState extends State<ApodButton> {
  bool _isExpanded = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
  const double baseSize = 220;

    final outerPadding = widget.expand ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0);

    return Padding(
      padding: outerPadding,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: Semantics(
          label: 'Astronomy Picture: ${widget.title} fecha ${widget.date}',
          button: true,
          child: Tooltip(
            message: widget.title,
            waitDuration: const Duration(milliseconds: 400),
            child: AnimatedScale(
              scale: _hover ? 1.02 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                elevation: _hover ? 4 : 0,
                shadowColor: isDark ? Colors.black : Colors.grey,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double targetSize = widget.expand ? constraints.maxWidth : (isDesktop ? baseSize * 1.05 : baseSize);
                      final double targetHeight = widget.expand ? constraints.maxHeight : targetSize;
                      return Container(
                        width: widget.expand ? double.infinity : targetSize,
                        height: targetHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: _hover && !isDark
                          ? Border.all(
                color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.4),
                              width: 1.5,
                            )
                          : null,
                    ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                proxiedImageUrl(widget.image),
                                width: targetSize,
                                height: targetHeight,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error_outline, color: Colors.red)),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.1),
                                      Colors.black.withValues(alpha: 0.85),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.date,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            ),
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
