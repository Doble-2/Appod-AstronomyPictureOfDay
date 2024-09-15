import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/organisms/day_picker.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';
import 'package:nasa_apod/ui/widgets/organisms/month_slider.dart';
import 'package:nasa_apod/ui/widgets/organisms/other_apod.dart';
import 'package:nasa_apod/ui/widgets/organisms/principal_apod.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(FetchMultipleApod());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
        child: Column(
            //  mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(top: 10.0), child: DayPicker()),
          Padding(
              padding: const EdgeInsets.only(top: 20.0), child: MonthSlider()),
          Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: PrincipalApod(onTap: () {})),
          Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: OtherApod(onTap: () {})),
        ]));
  }
}
