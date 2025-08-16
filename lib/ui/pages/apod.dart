import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_data.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_description.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_title.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/download_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';
import 'package:nasa_apod/utils/image_proxy.dart';

class ApodView extends StatefulWidget {
  const ApodView({super.key});

  @override
  State<ApodView> createState() => _ApodViewState();
}

class _ApodViewState extends State<ApodView> {
  bool _isLogged = false;
  List<String> _favoriteDates = [];

  Future<void> _loadFavorites() async {
    final favs = await AuthService().getFavorites();
    setState(() {
      _favoriteDates = List<String>.from(favs);
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchApod());
    _checkAuthentication();
    _loadFavorites();
  }

  Future<void> _checkAuthentication() async {
    // Replace with your actual authentication logic
    _isLogged = await AuthService().isLoggedIn();

    setState(() {
      _isLogged = _isLogged;
    });
  }

  String? translatedExplanation;
  bool explanationLoading = true;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;

    int currentIndex = 0;
    void onNavTap(int value) {
      setState(() {
        currentIndex = value;
      });
    }

    return Layout(
      hideNavBar: true,
      currentIndex: currentIndex,
      onNavTap: onNavTap,
      child: BlocBuilder<ApodBloc, ApodState>(
        builder: (context, state) {
          if (state.status == ApodStatus.loading) {
            return const _CenteredScrollable(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  SkeletonPrincipalApodButton(),
                  SizedBox(height: 24),
                  SkeletonTitle(),
                  SizedBox(height: 12),
                  SkeletonData(),
                  SizedBox(height: 24),
                  SkeletonDescription(),
                  SizedBox(height: 40),
                ],
              ),
            );
          } else if (state.status == ApodStatus.success &&
              state.apodData != null) {
            final apod = state.apodData!;
            final isImage = apod["media_type"] == "image";
            final isFavorite = _favoriteDates.contains(apod['date']);

            // Traducción diferida eliminada (no se llamaba). Se puede reintroducir bajo demanda.

            return LayoutBuilder(
              builder: (context, constraints) {
                final imageWidget = Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: isImage
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.all(0),
                                      child: Stack(
                                        children: [
                                          InteractiveViewer(
                                            panEnabled: true,
                                            minScale: 0.5,
                                            maxScale: 4,
                                            child: Center(
                                              child: Image.network(
                                                proxiedImageUrl(apod['hdurl'] ??
                                                    apod['url']),
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                        stack) =>
                                                    const Center(
                                                        child: Text(
                                                            'Error al cargar imagen en alta calidad')),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 16,
                                            right: 16,
                                            child: IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.white,
                                                  size: 30),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28.0),
                          child: AspectRatio(
                            aspectRatio: 6 / 3, // más cuadrado
                            child: isImage
                                ? Image.network(
                                    proxiedImageUrl(apod['url']),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, progress) =>
                                        progress == null
                                            ? child
                                            : const SkeletonPrincipalApodButton(),
                                    errorBuilder: (context, error, stack) =>
                                        const Center(child: Text('Error al cargar imagen')),
                                  )
                                : Container(
                                    color: Colors.black,
                                    child: const Center(
                                      child: Icon(Icons.play_circle_outline, color: Colors.white, size: 60),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Row(
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _isExpanded
                                  ? Row(
                                      children: [
                                        if (isImage)
                                          Bubble(
                                            child: Semantics(
                                              label: i10n.downloadApod,
                                              button: true,
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.download_rounded),
                                                tooltip: i10n.downloadApod,
                                                onPressed: () =>
                                                    saveNetworkImage(
                                                        context,
                                                        apod['url'],
                                                        apod['title']),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        if (_isLogged)
                                          Bubble(
                                            child: Semantics(
                                              label: isFavorite
                                                  ? i10n.removeFromFavorites
                                                  : i10n.addToFavorites,
                                              button: true,
                                              child: IconButton(
                                                icon: Icon(
                                                  isFavorite
                                                      ? Icons.favorite_rounded
                                                      : Icons
                                                          .favorite_border_rounded,
                                                  color: isFavorite
                                                      ? Colors.red
                                                      : null,
                                                ),
                                                tooltip: isFavorite
                                                    ? i10n.removeFromFavorites
                                                    : i10n.addToFavorites,
                                                onPressed: () async {
                                                  if (isFavorite) {
                                                    await AuthService()
                                                        .removeFavorite(
                                                            apod['date']);
                                                    if (mounted) {
                                                      setState(() {
                                                        _favoriteDates.remove(
                                                            apod['date']);
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(i10n
                                                              .removeFromFavorites),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    await AuthService()
                                                        .addFavorite(
                                                            apod['date']);
                                                    if (mounted) {
                                                      setState(() {
                                                        _favoriteDates
                                                            .add(apod['date']);
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(i10n
                                                              .addToFavorites),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              tooltip: _isExpanded ? 'Cerrar' : 'Más opciones',
                              onPressed: () =>
                                  setState(() => _isExpanded = !_isExpanded),
                              child: Icon(_isExpanded
                                  ? Icons.close_rounded
                                  : Icons.more_horiz_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                final metaAndDescription = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
            padding: const EdgeInsets.only(
              top: 24.0, left: 4, right: 4),
                      child: Text(
                        apod['title'],
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16.0, left: 4, right: 4),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 14,
                        runSpacing: 10,
                        children: [
                          _MetaChip(
                            icon: Icons.calendar_today_rounded,
                            label: apod['date'],
                          ),
                          if (apod['copyright'] != null)
                            _MetaChip(
                              icon: Icons.camera_alt_rounded,
                              label: apod['copyright'].replaceAll('\n', ' '),
                              maxWidth: 240,
                            ),
                          if (apod['media_type'] != null)
                            _MetaChip(
                              icon: Icons.category_rounded,
                              label: apod['media_type'],
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24.0, left: 4, right: 4, bottom: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Text(
                          translatedExplanation ?? apod['explanation'],
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.6, fontSize: 17),
                        ),
                      ),
                    ),
                    if (translatedExplanation == null)
                      Padding(
                        padding: const EdgeInsets.only( right: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
              color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.g_translate_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Builder(builder: (context) {
                                final code = Localizations.localeOf(context).languageCode;
                                final text = code == 'es'
                                    ? 'Próximamente traducción automática de la descripción '
                                    : 'Coming soon description auto-translation ';
                                return Text(
                                  text,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                    height: 1.2,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
                return _CenteredScrollable(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageWidget,
                      metaAndDescription,
                      const SizedBox(height: 48),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
                child: Text('No se pudieron cargar los datos.'));
          }
        },
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? maxWidth;
  const _MetaChip({required this.icon, required this.label, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Flexible(child: text),
      ],
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: content,
      ),
    );
  }
}

class _CenteredScrollable extends StatelessWidget {
  final Widget child;
  const _CenteredScrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxWidth = 1100.0;
        final horizontalPadding = constraints.maxWidth > maxWidth ? 32.0 : 16.0;
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
