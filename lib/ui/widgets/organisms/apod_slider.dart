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
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchMultipleApod());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        if (state.multiplestatus == ApodStatus.success &&
            state.multipleApodData.isNotEmpty &&
            state.apodData != null) {
          return SizedBox(
            height: 200,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(width: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final apodData = state.multipleApodData[index];
                return ApodButton(
                  image: apodData['url'],
                  title: apodData['title'],
                  date: apodData['date'],
                  author: 'author',
                );
              },
              itemCount: state.multipleApodData.length,
            ),
          );
        } else {
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
        }
      },
    );
  }
}
