import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/organisms/day_picker.dart';
import 'package:nasa_apod/ui/widgets/organisms/month_slider.dart';
import 'package:nasa_apod/ui/widgets/organisms/other_apod.dart';
import 'package:nasa_apod/ui/widgets/organisms/principal_apod.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';

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
  final i10n = AppLocalizations.of(context)!;
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
      filtersSection = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DayPicker(),
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 20.0),
            child: MonthSlider(),
          ),
        ],
      
      );
    }

    // Desktop ahora adopta un layout vertical similar a mobile para dar más protagonismo al APOD principal.
    final desktopBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
          if (state.status != ApodStatus.failed && state.multiplestatus != ApodStatus.failed) {
            return const SizedBox.shrink();
          }
          final isNasaDown = state.errorCode == 504;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isNasaDown ? i10n.nasaDownTitle : i10n.genericError,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<ApodBloc>().add(RefreshData()),
                  child: Text(i10n.retry),
                ),
              ],
            ),
          );
        }),
        filtersSection,
        // APOD principal grande centrado
        PrincipalApod(onTap: () {}),
        // Otros APODs debajo, usando estilo embebido (GlassPanel)
        OtherApod(onTap: () {}, embedded: true),
      ],
    );

    final mobileBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
          if (state.status != ApodStatus.failed && state.multiplestatus != ApodStatus.failed) {
            return const SizedBox.shrink();
          }
          final isNasaDown = state.errorCode == 504;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isNasaDown ? i10n.nasaDownTitle : i10n.genericError,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<ApodBloc>().add(RefreshData()),
                  child: Text(i10n.retry),
                ),
              ],
            ),
          );
        }),
        filtersSection,
        PrincipalApod(onTap: () {}),
        OtherApod(onTap: () {}),
      ],
    );

    // IMPORTANTE: No envolver en otro SingleChildScrollView porque el Layout
    // superior ya provee scroll vertical. El doble scroll en web móvil estaba
    // capturando eventos e impidiendo el desplazamiento.
    return MaxWidthContainer(
      child: isDesktop ? desktopBody : mobileBody,
    );
  }
}
