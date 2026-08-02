import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/organisms/day_picker.dart';
import 'package:nasa_apod/ui/widgets/organisms/month_slider.dart';
import 'package:nasa_apod/ui/widgets/organisms/other_apod.dart';
import 'package:nasa_apod/ui/widgets/organisms/principal_apod.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
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

  Widget _errorBanner() {
    final i10n = AppLocalizations.of(context)!;
    return BlocBuilder<ApodBloc, ApodState>(builder: (context, state) {
      if (state.status != ApodStatus.failed &&
          state.multiplestatus != ApodStatus.failed) {
        return const SizedBox.shrink();
      }
      final isNasaDown = state.errorCode == 504;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .error
                .withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isNasaDown ? i10n.nasaDownTitle : i10n.genericError,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final i10n = AppLocalizations.of(context)!;

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
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: MonthSlider(),
          ),
        ],
      );
    }

    // Encabezado con contexto: título de la sección + fecha seleccionada
    final header = BlocBuilder<ApodBloc, ApodState>(
      buildWhen: (prev, curr) => prev.date != curr.date,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: TitleArea(
            text: i10n.explore,
            subtitle: state.date,
          ),
        );
      },
    );

    // Desktop adopta un layout vertical similar a mobile para dar más protagonismo al APOD principal.
    // IMPORTANTE: No envolver en otro SingleChildScrollView porque el Layout
    // superior ya provee scroll vertical. El doble scroll en web móvil estaba
    // capturando eventos e impidiendo el desplazamiento.
    return MaxWidthContainer(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ApodBloc>().add(RefreshData());
          // Esperar a que el estado salga de loading
          await context.read<ApodBloc>().stream.firstWhere(
                (s) => s.status != ApodStatus.loading,
              );
        },
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            _errorBanner(),
            filtersSection,
            // APOD principal grande centrado
            const PrincipalApod(),
            // Otros APODs debajo, estilo embebido en desktop
            OtherApod(embedded: isDesktop),
          ],
        ),
      ),
    );
  }
}
