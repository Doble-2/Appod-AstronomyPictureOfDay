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
    final isDesktop = context.isDesktop;

    Widget header([int? count]) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 12),
        child: Row(
          children: [
            Icon(Icons.favorite_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              i10n.favorites + (count != null ? ' ($count)' : ''),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    if (!isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_person_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          i10n.pleaseLoginToSeeFavorites,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/login'),
                        icon: const Icon(Icons.login_rounded),
                        label: Text(i10n.login),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/register'),
                        icon: const Icon(Icons.person_add_rounded),
                        label: Text(i10n.register),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        final crossCount = _crossAxisCount(context);
        final aspect = _childAspectRatio(context);

        if (state.favoriteApodStatus == ApodStatus.loading) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: aspect,
                  ),
                  itemCount: isDesktop ? 12 : 8,
                  itemBuilder: (context, index) => const SkeletonPrincipalApodButton(),
                ),
              ],
            ),
          );
        } else if (state.favoriteApodStatus == ApodStatus.success) {
          if (state.favoriteApodData.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header(0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite_outline, size: 36, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aún no tienes favoritos',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                          icon: const Icon(Icons.explore_rounded),
                          label: const Text('Explorar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(state.favoriteApodData.length),
                GridView.builder(
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
              ],
            ),
          );
        } else if (state.favoriteApodStatus == ApodStatus.failed) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error al cargar los favoritos.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
