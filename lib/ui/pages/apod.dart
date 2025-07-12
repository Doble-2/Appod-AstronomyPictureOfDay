import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_data.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_description.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_title.dart';
import 'package:simplytranslate/simplytranslate.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
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
        child: BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
      if (state.status == ApodStatus.loading) {
        return const Column(
          children: [
            SkeletonPrincipalApodButton(),
            SkeletonTitle(),
            SkeletonData(),
            SkeletonDescription()
          ],
        );
      } else if (state.status == ApodStatus.success && state.apodData != null) {
        Future<void> translateExplanation(
            BuildContext context, SimplyTranslator st) async {
          if (translatedExplanation == null) {
            setState(() {
              explanationLoading = false;
            });
            bool isWorking = await st.isSimplyInstanceWorking("st.tokhmi.xyz");
            if (isWorking) {
              st.setSimplyInstance = "st.tokhmi.xyz";

              final translatedText =
                  await st.trSimply(state.apodData!['explanation'], "en", 'es');
              setState(() {
                translatedExplanation = translatedText;
                explanationLoading = true;
              });
            } else {
              setState(() {
                explanationLoading = true;
              });
            }
          }
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Image.network(
                      state.apodData!['url'],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _isExpanded
                              ? Column(
                                  children: [
                                    FloatingActionButton(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      onPressed: () {
                                        if (_isLogged) {
                                          AuthService().addFavorite(
                                              state.apodData!['date']);
                                        }
                                      },
                                      mini: true,
                                      child: Icon(
                                        Icons.favorite,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ), // Icono del botón principal
                                    ),
                                    FloatingActionButton(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      onPressed: () {
                                        saveNetworkImage(
                                            state.apodData!['hdurl'],
                                            state.apodData!['title']);
                                      },
                                      mini: true,
                                      child: Icon(Icons.download,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ],
                                )
                              : Container(),
                          FloatingActionButton(
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Icon(Icons.add,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
          Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 10),
              child: TitleArea(text: state.apodData!['title'])),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 10),
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.calendar_today,
                        size: 20,
                      ),
                    ),
                    Text(
                      state.apodData!['date'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5, left: 30),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        state.apodData!['copyright'] != null
                            ? state.apodData!['copyright'].replaceAll('\n', '')
                            : 'Nasa',
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          explanationLoading == true
              ? Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 10, bottom: 15),
                  child: Text(
                      translatedExplanation ?? state.apodData!['explanation'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      )))
              : const SkeletonDescription(),
          translatedExplanation == null
              ? Padding(
                  padding:
                      const EdgeInsets.only(top: 5.0, left: 10, bottom: 30),
                  child: GestureDetector(
                      onTap: () => translateExplanation(context, st),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Translate',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                left: 7,
                              ),
                              child: Icon(
                                Icons.g_translate,
                                color: Theme.of(context).colorScheme.primary,
                              ))
                        ],
                      )),
                )
              : Container(),
        ]);
      } else {
        return const Text('Failed to load data');
      }
    }));
  }
}
