import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/organisms/day_picker.dart';
import 'package:nasa_apod/ui/widgets/organisms/month_slider.dart';
import 'package:nasa_apod/ui/widgets/organisms/other_apod.dart';
import 'package:nasa_apod/ui/widgets/organisms/principal_apod.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';

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
    final isDesktop = context.isDesktop;

    // Layout contract:
    // Mobile: Column (DayPicker, MonthSlider, Principal, Other)
    // Desktop: Row for filters (DayPicker expanded + MonthSlider to right), then spaced sections with larger vertical rhythm.

    Widget filtersSection;
    if (isDesktop) {
      filtersSection = Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: const DayPicker(),
            ),
          ),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                child: const MonthSlider(),
              ),
            ),
        ],
      );
    } else {
      filtersSection = const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: DayPicker(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: MonthSlider(),
          ),
        ],
      ),
      );
    }

    // Desktop ahora adopta un layout vertical similar a mobile para dar más protagonismo al APOD principal.
    final desktopBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filtersSection,
        const SizedBox(height: 28),
        // APOD principal grande centrado
        PrincipalApod(onTap: () {}),
        const SizedBox(height: 40),
        // Otros APODs debajo, usando estilo embebido (GlassPanel)
        OtherApod(onTap: () {}, embedded: true),
        const SizedBox(height: 56),
      ],
    );

    final mobileBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filtersSection,
        const SizedBox(height: 28),
        PrincipalApod(onTap: () {}),
        const SizedBox(height: 32),
        OtherApod(onTap: () {}),
        const SizedBox(height: 40),
      ],
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: MaxWidthContainer(
        child: isDesktop ? desktopBody : mobileBody,
      ),
    );
  }
}
