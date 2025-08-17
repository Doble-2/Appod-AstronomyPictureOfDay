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
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class ApodView extends StatefulWidget {
  final String? date; // yyyy-MM-dd, opcional
  const ApodView({super.key, this.date});

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
    if (widget.date != null && widget.date!.isNotEmpty) {
      context.read<ApodBloc>().add(ChangeDate(widget.date!));
    } else {
      context.read<ApodBloc>().add(FetchApod());
    }
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
                final isDesktop = context.isDesktop;
                final mediaWidget = Padding(
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
                            aspectRatio: isDesktop ? 16 / 9 : 6 / 3,
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
                                : _ApodVideo(url: apod['url']),
                          ),
                        ),
                      ),
                      // Acciones: en desktop se muestran siempre; en mobile se expanden con FAB
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: isDesktop
                            ? Row(
                                children: [
                                  if (isImage)
                                    Bubble(
                                      child: Semantics(
                                        label: i10n.downloadApod,
                                        button: true,
                                        child: IconButton(
                                          icon: const Icon(Icons.download_rounded),
                                          tooltip: i10n.downloadApod,
                                          onPressed: () => saveNetworkImage(context, apod['url'], apod['title']),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (_isLogged)
                                    Bubble(
                                      child: Semantics(
                                        label: isFavorite ? i10n.removeFromFavorites : i10n.addToFavorites,
                                        button: true,
                                        child: IconButton(
                                          icon: Icon(
                                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            color: isFavorite ? Colors.red : null,
                                          ),
                                          tooltip: isFavorite ? i10n.removeFromFavorites : i10n.addToFavorites,
                                          onPressed: () async {
                                            if (isFavorite) {
                                              await AuthService().removeFavorite(apod['date']);
                                              if (mounted) {
                                                setState(() {
                                                  _favoriteDates.remove(apod['date']);
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(i10n.removeFromFavorites), duration: const Duration(seconds: 2)),
                                                );
                                              }
                                            } else {
                                              await AuthService().addFavorite(apod['date']);
                                              if (mounted) {
                                                setState(() {
                                                  _favoriteDates.add(apod['date']);
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(i10n.addToFavorites), duration: const Duration(seconds: 2)),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Row(
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
                                                      icon: const Icon(Icons.download_rounded),
                                                      tooltip: i10n.downloadApod,
                                                      onPressed: () => saveNetworkImage(context, apod['url'], apod['title']),
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              if (_isLogged)
                                                Bubble(
                                                  child: Semantics(
                                                    label: isFavorite ? i10n.removeFromFavorites : i10n.addToFavorites,
                                                    button: true,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                        color: isFavorite ? Colors.red : null,
                                                      ),
                                                      tooltip: isFavorite ? i10n.removeFromFavorites : i10n.addToFavorites,
                                                      onPressed: () async {
                                                        if (isFavorite) {
                                                          await AuthService().removeFavorite(apod['date']);
                                                          if (mounted) {
                                                            setState(() {
                                                              _favoriteDates.remove(apod['date']);
                                                            });
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text(i10n.removeFromFavorites), duration: const Duration(seconds: 2)),
                                                            );
                                                          }
                                                        } else {
                                                          await AuthService().addFavorite(apod['date']);
                                                          if (mounted) {
                                                            setState(() {
                                                              _favoriteDates.add(apod['date']);
                                                            });
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text(i10n.addToFavorites), duration: const Duration(seconds: 2)),
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
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    tooltip: _isExpanded ? 'Cerrar' : 'Más opciones',
                                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                                    child: Icon(_isExpanded ? Icons.close_rounded : Icons.more_horiz_rounded),
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
                    if (isDesktop)
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 4, right: 4),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (isImage)
                              FilledButton.icon(
                                onPressed: () => saveNetworkImage(context, apod['url'], apod['title']),
                                icon: const Icon(Icons.download_rounded),
                                label: Text(i10n.downloadApod),
                              ),
                            if (_isLogged)
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final favored = isFavorite;
                                  if (favored) {
                                    await AuthService().removeFavorite(apod['date']);
                                    if (mounted) {
                                      setState(() => _favoriteDates.remove(apod['date']));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(i10n.removeFromFavorites), duration: const Duration(seconds: 2)),
                                      );
                                    }
                                  } else {
                                    await AuthService().addFavorite(apod['date']);
                                    if (mounted) {
                                      setState(() => _favoriteDates.add(apod['date']));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(i10n.addToFavorites), duration: const Duration(seconds: 2)),
                                      );
                                    }
                                  }
                                },
                                icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                                label: Text(isFavorite ? i10n.removeFromFavorites : i10n.addToFavorites),
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
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: mediaWidget),
                            const SizedBox(width: 28),
                            Expanded(flex: 5, child: metaAndDescription),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            mediaWidget,
                            metaAndDescription,
                            const SizedBox(height: 48),
                          ],
                        ),
                );
              },
            );
          } else {
            final isNasaDown = state.errorCode == 504;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        isNasaDown
                            ? i10n.nasaDownTitle
                            : i10n.genericError,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isNasaDown
                            ? i10n.nasaDownBody(state.errorCode ?? 504)
                            : (state.errorMessage ?? i10n.genericError),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<ApodBloc>().add(FetchApod());
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(i10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            );
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
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

class _ApodVideo extends StatefulWidget {
  final String url;
  const _ApodVideo({required this.url});

  @override
  State<_ApodVideo> createState() => _ApodVideoState();
}

class _ApodVideoState extends State<_ApodVideo> {
  late final String _url = widget.url;
  YoutubePlayerController? _ytController;

  String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      // watch?v=ID
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      // embed/ID
      final idx = uri.pathSegments.indexOf('embed');
      if (idx != -1 && uri.pathSegments.length > idx + 1) {
        return uri.pathSegments[idx + 1];
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final ytId = _extractYouTubeId(_url);
    if (ytId != null) {
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: ytId,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ytController != null) {
      return YoutubePlayer(controller: _ytController!);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: FilledButton.icon(
            onPressed: () async {
              final uri = Uri.tryParse(_url);
              if (uri != null) {
                await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Abrir video'),
          ),
        ),
      ],
    );
  }
}
