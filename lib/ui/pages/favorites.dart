import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/apod_button.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';

class FavoritesView extends StatefulWidget {
  final AuthService authService;

  const FavoritesView({super.key, required this.authService});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  bool isLoggedIn = false;

  Future<void> _checkAuthentication() async {
    isLoggedIn = await AuthService().isLoggedIn();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    context.read<ApodBloc>().add(FetchFavoriteApod());
  }

  int _crossAxisCount(BuildContext context) {
    if (context.isDesktop && !context.isXl) return 4;
    if (context.isXl) return 5;
    if (context.isMd) return 3; // rango md (>=905 <1240)
    if (context.isSm) return 3; // tablets pequeñas / landscape
    return 2; // móvil
  }

  double _childAspectRatio(BuildContext context) {
    if (context.isXl) return 0.9;
    if (context.isDesktop) return 0.85;
    if (context.isMd) return 0.8;
    if (context.isSm) return 0.78;
    return 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    if (!isLoggedIn) {
      return Center(
        child: Text(
          i10n.pleaseLoginToSeeFavorites,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        final crossCount = _crossAxisCount(context);
        final aspect = _childAspectRatio(context);

        if (state.favoriteApodStatus == ApodStatus.loading) {
          return SingleChildScrollView(
            child: MaxWidthContainer(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: aspect,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) => const SkeletonPrincipalApodButton(),
                ),
              ),
            ),
          );
        } else if (state.favoriteApodStatus == ApodStatus.success) {
          if (state.favoriteApodData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no tienes favoritos',
                    style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: MaxWidthContainer(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 40),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: aspect,
                  ),
                  itemCount: state.favoriteApodData.length,
                  itemBuilder: (context, index) {
                    final apod = state.favoriteApodData[index]!;
                    return ApodButton(
                      title: apod['title'] ?? 'No Title',
                      date: apod['date'] ?? 'No Date',
                      author: apod['copyright'] ?? 'No Author',
                      image: apod['url'] ?? '',
                      showRemoveButton: true,
                      onRemove: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final apodBloc = context.read<ApodBloc>();
                        await widget.authService.removeFavorite(apod['date']);
                        if (!mounted) return;
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Favorito eliminado con éxito'),
                          ),
                        );
                        apodBloc.add(FetchFavoriteApod());
                      },
                    );
                  },
                ),
              ),
            ),
          );
        } else if (state.favoriteApodStatus == ApodStatus.failed) {
          return Center(
            child: Text(
              'Error al cargar los favoritos.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
