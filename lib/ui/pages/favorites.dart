import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/common.dart';

class FavoritesView extends StatefulWidget {
  final AuthService authService;
  const FavoritesView({super.key, required this.authService});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    widget.authService.isLoggedIn().then((value) {
      if (mounted) setState(() => _isLoggedIn = value);
    });
    _reload();
  }

  void _reload() => context.read<ApodBloc>().add(FetchFavoriteApod());

  Future<void> _remove(String date) async {
    final i10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await widget.authService.removeFavorite(date);
    if (!mounted) return;
    _reload();
    messenger.showSnackBar(SnackBar(content: Text(i10n.favoriteRemoved)));
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(i10n.favorites, style: theme.textTheme.displaySmall),
          if (!_isLoggedIn) ...[
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(i10n.favoritesLocalHint, style: theme.textTheme.bodyMedium),
                TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login), child: Text(i10n.login)),
              ],
            ),
          ],
          const SizedBox(height: 24),
          BlocBuilder<ApodBloc, ApodState>(
            buildWhen: (a, b) => a.favoriteApodStatus != b.favoriteApodStatus || a.favoriteApodData != b.favoriteApodData,
            builder: (context, state) => switch (state.favoriteApodStatus) {
              ApodStatus.loading => const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator())),
              ApodStatus.failed => StateMessage(
                  icon: Icons.cloud_off_rounded,
                  title: i10n.favoritesError,
                  body: apodErrorText(i10n, state.errorCode),
                  actionLabel: i10n.retry,
                  onAction: _reload,
                ),
              ApodStatus.success when state.favoriteApodData.isEmpty => StateMessage(
                  icon: Icons.favorite_border_rounded,
                  title: i10n.noFavoritesYet,
                  actionLabel: i10n.backToToday,
                  onAction: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                ),
              ApodStatus.success => ApodGrid(
                  children: [
                    for (final apod in state.favoriteApodData)
                      ApodCard(apod: apod as Map, onRemove: () => _remove(apod['date'] as String), onReturned: _reload),
                  ],
                ),
            },
          ),
        ],
      ),
    );
  }
}
