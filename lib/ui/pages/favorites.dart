import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/apod_button.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_principal_apod_button.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';

class FavoritesView extends StatefulWidget {
  final AuthService authService;

  const FavoritesView({super.key, required this.authService});

  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchFavoriteApod());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: BlocBuilder<ApodBloc, ApodState>(
        builder: (context, state) {
          if (state.favoriteApodStatus == ApodStatus.loading) {
            return Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: 6, // Placeholder count
                itemBuilder: (context, index) => const SkeletonPrincipalApodButton(),
              ),
            );
          } else if (state.favoriteApodStatus == ApodStatus.success) {
            if (state.favoriteApodData.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aún no tienes favoritos',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // Ajusta según el diseño deseado
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
                      await widget.authService.removeFavorite(apod['date']);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Favorito eliminado con éxito'),
                        ),
                      );
                      context.read<ApodBloc>().add(FetchFavoriteApod());
                    },
                  );
                },
              ),
            );
          } else if (state.favoriteApodStatus == ApodStatus.failed) {
            return const Center(
              child: Text(
                'Error al cargar los favoritos.',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const SizedBox.shrink(); // Estado inicial o no manejado
          }
        },
      ),
    );
  }
}
