import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/apod_button.dart';
import 'package:nasa_apod/ui/widgets/molecules/month_button.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/molecules/skeleton_apod_button.dart';
// Asegúrate de importar tu bloc

class ApodSlider extends StatefulWidget {
  ApodSlider({
    Key? key,
  }) : super(key: key);

  @override
  _ApodSliderState createState() => _ApodSliderState();
}

class _ApodSliderState extends State<ApodSlider> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        if (state.multiplestatus == ApodStatus.success &&
            state.multipleApodData.isNotEmpty) {
          return SizedBox(
            height: 200,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(width: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final apodData = state.multipleApodData[index];
                print('true');
                return ApodButton(
                  image: apodData['url'],
                  title: apodData['title'],
                  date: apodData['date'],
                  author: apodData['copyright'] != null
                      ? apodData['copyright']
                      : 'Nasa',
                );
              },
              itemCount: state.multipleApodData.length,
            ),
          );
        } else if (state.multiplestatus != ApodStatus.failed) {
          return SizedBox(
            height: 200,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(width: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return SkeletonApodButton();
              },
              itemCount: 7,
            ),
          );
        } else {
          return SizedBox(
            height: 200,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(width: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                      boxShadow: [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 200,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                gradient: LinearGradient(
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
                            Positioned(
                              child: Text('Error de conexion'),
                              top: 10,
                              left: 10,
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                            width: 200,
                            height: 60,
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: LinearGradient(
                                colors: [Color(0xFF161616), Color(0xFF1A1A1A)],
                                stops: [0.5, 2],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
              },
              itemCount: 7,
            ),
          );
        }
      },
    );
  }
}
