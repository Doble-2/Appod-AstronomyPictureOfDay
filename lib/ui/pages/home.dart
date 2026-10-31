import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:nasa_apod/utils/apod_dates.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Coming back to this tab keeps the day the reader was looking at.
    final bloc = context.read<ApodBloc>();
    if (bloc.state.apodData == null) bloc.add(RefreshData());
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        if (state.status == ApodStatus.failed) {
          return PageBody(
            child: Column(
              children: [
                _DateBar(date: state.date),
                StateMessage(
                  icon: Icons.cloud_off_rounded,
                  title: i10n.genericError,
                  body: apodErrorText(i10n, state.errorCode),
                  actionLabel: i10n.retry,
                  onAction: () => context.read<ApodBloc>().add(RefreshData()),
                ),
              ],
            ),
          );
        }
        // While another day loads, the current one stays on screen instead of flashing away.
        final loading = state.status == ApodStatus.loading || state.multiplestatus == ApodStatus.loading;
        final others = state.multipleApodData.where((a) => a['url'] != null).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Hero(apod: state.apodData),
            SizedBox(height: 2, child: loading ? const LinearProgressIndicator() : null),
            PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateBar(date: state.date),
                  const SizedBox(height: 32),
                  if (others.isNotEmpty) ...[
                    Text(i10n.previousDays, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    ApodGrid(children: [for (final apod in others) ApodCard(apod: apod)]),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The picture of the day, edge to edge. White text on a dark fade in both
/// themes, because it always sits on a photograph.
class _Hero extends StatelessWidget {
  final Map<String, dynamic>? apod;
  const _Hero({required this.apod});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isDesktop = context.isDesktop;
    final height = isDesktop ? (size.height * 0.64).clamp(420.0, 720.0) : (size.height * 0.58).clamp(340.0, 560.0);
    final data = apod;
    if (data == null) {
      return SizedBox(height: height, width: double.infinity, child: ColoredBox(color: theme.colorScheme.surfaceContainer));
    }
    final date = data['date'] as String;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Semantics(
        button: true,
        label: '${data['title']}. ${i10n.readMore}',
        child: InkWell(
          onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/apod/$date'),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ApodImage(url: (data['url'] ?? '') as String, isVideo: data['media_type'] == 'video'),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.4, 1],
                    colors: [Colors.transparent, Color(0xD9000000)],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: isDesktop ? 40 : 20,
                child: PageBody(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            longDate(date, Localizations.localeOf(context).languageCode),
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (data['title'] ?? '') as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: (isDesktop ? theme.textTheme.displaySmall : theme.textTheme.headlineMedium)?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Moves through the archive one day at a time, or jumps with the calendar.
class _DateBar extends StatelessWidget {
  final String date;
  const _DateBar({required this.date});

  void _go(BuildContext context, String? target) {
    if (target != null) context.read<ApodBloc>().add(ChangeDate(target));
  }

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<ApodBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(date) ?? DateTime.now(),
      firstDate: firstApodDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      bloc.add(ChangeDate('${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final previous = shiftDay(date, -1);
    final next = shiftDay(date, 1);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: i10n.previousDay,
                onPressed: previous == null ? null : () => _go(context, previous),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Tooltip(
                message: i10n.chooseDate,
                child: TextButton.icon(
                  onPressed: () => _pick(context),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(longDate(date, Localizations.localeOf(context).languageCode)),
                ),
              ),
              IconButton(
                tooltip: i10n.nextDay,
                onPressed: next == null ? null : () => _go(context, next),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          if (date != todayIso())
            TextButton(onPressed: () => _go(context, todayIso()), child: Text(i10n.backToToday)),
        ],
      ),
    );
  }
}
