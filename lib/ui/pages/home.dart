import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/organisms/day_picker.dart';
import 'package:nasa_apod/ui/widgets/organisms/month_slider.dart';
import 'package:nasa_apod/ui/widgets/organisms/other_apod.dart';
import 'package:nasa_apod/ui/widgets/organisms/principal_apod.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    context.read<ApodBloc>().add(RefreshData());
  }

  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: DayPicker(),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: MonthSlider(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: PrincipalApod(onTap: () {}),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: OtherApod(onTap: () {}),
              ),
            ],
          ),
        );

  }
}
