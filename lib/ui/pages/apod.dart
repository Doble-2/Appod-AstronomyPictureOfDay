import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widget_zoom/widget_zoom.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchApod());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
        child: BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
      if (state.status == ApodStatus.loading) {
        return const SkeletonPrincipalApodButton();
      } else if (state.status == ApodStatus.success && state.apodData != null) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: WidgetZoom(
                      heroAnimationTag: 'tag',
                      zoomWidget: Image.network(
                        state.apodData!['url'],
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              saveNetworkImage(state.apodData!['hdurl'],
                                  state.apodData!['title']);
                            },
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                          )
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
          Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10, bottom: 30),
              child: Text(state.apodData!['explanation'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  )))
        ]);
      } else {
        return const Text('Failed to load data');
      }
    }));
  }
}
