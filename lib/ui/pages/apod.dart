import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_data.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_description.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_title.dart';
import 'package:simplytranslate/simplytranslate.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/download_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
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

    final st = SimplyTranslator(EngineType.google);
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
            return const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonPrincipalApodButton(),
                  SkeletonTitle(),
                  SkeletonData(),
                  SkeletonDescription(),
                ],
              ),
            );
          } else if (state.status == ApodStatus.success && state.apodData != null) {
            final apod = state.apodData!;
            final isImage = apod["media_type"] == "image";
            final isFavorite = _favoriteDates.contains(apod['date']);

            void translateExplanation() async {
              if (translatedExplanation != null) return;
              setState(() => explanationLoading = true);
              final isWorking = await st.isSimplyInstanceWorking("st.tokhmi.xyz");
              if (isWorking) {
                st.setSimplyInstance = "st.tokhmi.xyz";
                final translatedText = await st.trSimply(apod['explanation'], "en", 'es');
                if (mounted) {
                  setState(() {
                    translatedExplanation = translatedText;
                    explanationLoading = false;
                  });
                }
              } else {
                if (mounted) setState(() => explanationLoading = false);
              }
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= AppBreakpoints.md;
                final imageWidget = Padding(
                  padding: const EdgeInsets.only(top: 16.0),
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
                                                proxiedImageUrl(apod['hdurl'] ?? apod['url']),
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stack) => const Center(
                                                    child: Text('Error al cargar imagen en alta calidad')),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 16,
                                            right: 16,
                                            child: IconButton(
                                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                              onPressed: () => Navigator.of(context).pop(),
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
                          borderRadius: BorderRadius.circular(24.0),
                          child: isImage
                              ? Image.network(
                                  proxiedImageUrl(apod['url']),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: isWide ? (constraints.maxWidth * 0.45 / (16 / 9)).clamp(260, 520) : 400,
                                  loadingBuilder: (context, child, progress) =>
                                      progress == null ? child : const SkeletonPrincipalApodButton(),
                                  errorBuilder: (context, error, stack) =>
                                      const Center(child: Text('Error al cargar imagen')),
                                )
                              : AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Container(
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
                                                  isFavorite
                                                      ? Icons.favorite_rounded
                                                      : Icons.favorite_border_rounded,
                                                  color: isFavorite ? Colors.red : null,
                                                ),
                                                tooltip: isFavorite
                                                    ? i10n.removeFromFavorites
                                                    : i10n.addToFavorites,
                                                onPressed: () async {
                                                  if (isFavorite) {
                                                    await AuthService().removeFavorite(apod['date']);
                                                    if (mounted) {
                                                      setState(() {
                                                        _favoriteDates.remove(apod['date']);
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(i10n.removeFromFavorites),
                                                          duration: const Duration(seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    await AuthService().addFavorite(apod['date']);
                                                    if (mounted) {
                                                      setState(() {
                                                        _favoriteDates.add(apod['date']);
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(i10n.addToFavorites),
                                                          duration: const Duration(seconds: 2),
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
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              tooltip: _isExpanded ? 'Cerrar' : 'Más opciones',
                              onPressed: () => setState(() => _isExpanded = !_isExpanded),
                              child: Icon(
                                  _isExpanded ? Icons.close_rounded : Icons.more_horiz_rounded),
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
                      padding: EdgeInsets.only(top: isWide ? 0 : 24.0, left: 4, right: 4),
                      child: Text(apod['title'], style: Theme.of(context).textTheme.headlineMedium),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 4, right: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text(apod['date'], style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 24),
                          if (apod['copyright'] != null) ...[
                            const Icon(Icons.camera_alt_rounded, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                apod['copyright'].replaceAll('\n', ' '),
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 4, right: 4, bottom: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Text(
                          translatedExplanation ?? apod['explanation'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ),
                    ),
                    if (translatedExplanation == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32, right: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: explanationLoading
                              ? const CircularProgressIndicator()
                              : TextButton.icon(
                                  onPressed: translateExplanation,
                                  icon: const Icon(Icons.g_translate_rounded),
                                  label: const Text('Traducir'),
                                ),
                        ),
                      ),
                  ],
                );
                if (isWide) {
                  return SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(flex: 5, child: imageWidget),
                        const SizedBox(width: 32),
                        Flexible(flex: 5, child: metaAndDescription),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageWidget,
                      metaAndDescription,
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No se pudieron cargar los datos.'));
          }
        },
      ),
    );
  }
}
