import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/bubble.dart';
import 'package:nasa_apod/ui/widgets/molecules/download_apod.dart';

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
    context.read<ApodBloc>().add(FetchFavoriteApod());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
        child: BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
      if (state.favoriteApodStatus == ApodStatus.loading) {
        return const Text('data');
      } else if (state.favoriteApodStatus == ApodStatus.success &&
          state.favoriteApodData != []) {
        return Column(children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: ListView.builder(
                itemCount: state.favoriteApodData.length,
                itemBuilder: (context, index) {
                  return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                          onTap: () {
                            context.read<ApodBloc>().add(
                                  ChangeDate(
                                      state.favoriteApodData[index]!['date']),
                                );
                            Get.toNamed('/appod');
                          },
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40.0),
                                child: Image.network(
                                  state.favoriteApodData[index]!['url'],
                                  errorBuilder: (context, error, stackTrace) {
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 250,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF161616),
                                                Color(0xFF1A1A1A)
                                              ],
                                              stops: [0.2, 2],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        ),
                                        const Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Text('Error de conexion'),
                                        )
                                      ],
                                    );
                                  },
                                  fit: BoxFit.cover,
                                  height: 250,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 20.0),
                                      child: GestureDetector(
                                          onTap: () async {
                                            await AuthService().removeFavorite(
                                                state.favoriteApodData[index]![
                                                    'date']);
                                            context
                                                .read<ApodBloc>()
                                                .add(FetchFavoriteApod());
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.white,
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          )))),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 250,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5.0),
                                              child: Bubble(
                                                child: Text(
                                                  state.favoriteApodData[
                                                      index]!['title'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Color(0xFF606060),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Bubble(
                                                child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Icon(
                                                    Icons.calendar_today,
                                                    color: Color(0xFF606060),
                                                    size: 20,
                                                  ),
                                                ),
                                                Text(
                                                  state.favoriteApodData[
                                                      index]!['date'],
                                                  style: const TextStyle(
                                                    color: Color(0xFF606060),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ))
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            saveNetworkImage(
                                                state.favoriteApodData[index]![
                                                    'hdurl'],
                                                state.favoriteApodData[index]![
                                                    'title']);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.white,
                                            ),
                                            child: Icon(
                                              Icons.download,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )));
                },
              ))
        ]);
      } else
        return const Text('failed');
    }));
  }
}
