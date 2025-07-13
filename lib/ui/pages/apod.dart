import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_data.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_description.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_title.dart';
import 'package:simplytranslate/simplytranslate.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/download_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';

class ApodView extends StatefulWidget {
  const ApodView({super.key});

  @override
  _ApodViewState createState() => _ApodViewState();
}

class _ApodViewState extends State<ApodView> {
  bool _isLogged = false;

  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchApod());
    _checkAuthentication();
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
    final st = SimplyTranslator(EngineType.google);

    return Layout(
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- IMAGEN PRINCIPAL Y BOTONES FLOTANTES ---
                  Padding(
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
                                                  apod['hdurl'] ?? apod['url'],
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
                                    apod['url'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 400,
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
                                              child: IconButton(
                                                icon: const Icon(Icons.download_rounded),
                                                tooltip: 'Descargar',
                                                onPressed: () => saveNetworkImage(context, apod['url'], apod['title']),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          if (_isLogged)
                                            Bubble(
                                              child: IconButton(
                                                icon: const Icon(Icons.favorite_border_rounded),
                                                tooltip: 'Guardar en favoritos',
                                                onPressed: () {
                                                  // Lógica para favoritos
                                                },
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
                                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                                child: Icon(_isExpanded ? Icons.close_rounded : Icons.more_horiz_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- TÍTULO ---
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, left: 4, right: 4),
                    child: Text(apod['title'], style: Theme.of(context).textTheme.headlineMedium),
                  ),

                  // --- FECHA Y AUTOR ---
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

                  // --- EXPLICACIÓN Y TRADUCCIÓN ---
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, left: 4, right: 4, bottom: 16),
                    child: Text(
                      translatedExplanation ?? apod['explanation'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
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
              ),
            );
          } else {
            return const Center(child: Text('No se pudieron cargar los datos.'));
          }
        },
      ),
    );
  }
}
