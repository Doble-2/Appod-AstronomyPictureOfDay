import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/data/nasa.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:nasa_apod/utils/apod_dates.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Days the carousel shows; the wall below continues from there.
  static const _carouselDays = 5;

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
    final theme = Theme.of(context);
    return BlocConsumer<ApodBloc, ApodState>(
      // NASA publishes around midnight in New York, so ahead of that time zone
      // today's picture may not exist yet. Open the latest one instead of an error.
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == ApodStatus.failed && state.errorCode == 404 && state.date == todayIso()) {
          final yesterday = shiftDay(state.date, -1);
          if (yesterday != null) context.read<ApodBloc>().add(ChangeDate(yesterday));
        }
      },
      builder: (context, state) {
        if (state.status == ApodStatus.failed) {
          return PageBody(
            child: StateMessage(
              icon: Icons.cloud_off_rounded,
              title: i10n.genericError,
              body: apodErrorText(i10n, state.errorCode),
              actionLabel: i10n.retry,
              onAction: () => context.read<ApodBloc>().add(RefreshData()),
            ),
          );
        }
        final others = state.multipleApodData.where((a) => a['url'] != null).toList();
        final current = state.apodData;
        final carousel = [if (current != null) current, ...others.take(_carouselDays - 1)];
        final wall = others.skip(_carouselDays - 1).toList();
        final loading = state.multiplestatus == ApodStatus.loading && others.isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageBody(child: _Heading(date: state.date)),
            const SizedBox(height: 18),
            _Carousel(key: ValueKey(state.date), days: carousel, date: state.date),
            const SizedBox(height: 34),
            _OnThisDay(key: ValueKey('otd-${state.date}'), date: state.date),
            const SizedBox(height: 34),
            PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i10n.fromTheArchive, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  if (loading)
                    ApodMasonry<int>(
                      items: List.generate(8, (i) => i),
                      builder: (_, shape) => AspectRatio(aspectRatio: shape, child: const Skeleton()),
                    )
                  else
                    ApodMasonry<dynamic>(
                      key: ValueKey('wall-${state.date}'),
                      items: wall,
                      builder: (apod, shape) => ApodCard(apod: apod as Map, aspectRatio: shape),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A big, plain statement of where the reader is in time.
class _Heading extends StatelessWidget {
  final String date;
  const _Heading({required this.date});

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<ApodBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(date) ?? DateTime.now(),
      firstDate: firstApodDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) bloc.add(ChangeDate(DateFormat('yyyy-MM-dd').format(picked)));
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isToday = date == todayIso();
    final parsed = DateTime.tryParse(date) ?? DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toBeginningOfSentenceCase(DateFormat.MMMEd(locale).format(parsed)),
                style: theme.textTheme.labelMedium?.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                isToday ? i10n.today : DateFormat.yMMMd(locale).format(parsed),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.displayLarge,
              ),
            ],
          ),
        ),
        if (!isToday)
          IconButton.filledTonal(
            tooltip: i10n.backToToday,
            onPressed: () => context.read<ApodBloc>().add(ChangeDate(todayIso())),
            icon: const Icon(Icons.today_rounded),
          ),
        const SizedBox(width: 6),
        IconButton.filled(
          tooltip: i10n.chooseDate,
          onPressed: () => _pick(context),
          style: IconButton.styleFrom(minimumSize: const Size(52, 52), backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
          icon: const Icon(Icons.calendar_month_rounded),
        ),
      ],
    );
  }
}

/// Big cards with the neighbors peeking in. The one in focus colors the screen.
class _Carousel extends StatefulWidget {
  final List<dynamic> days;
  final String date;
  const _Carousel({super.key, required this.days, required this.date});

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  PageController? _controller;
  int _page = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    final fraction = width < 600 ? 0.86 : (820 / width).clamp(0.4, 0.8);
    if (_controller == null || _controller!.viewportFraction != fraction) {
      _controller?.dispose();
      _controller = PageController(viewportFraction: fraction, initialPage: _page);
    }
    _syncAmbient();
  }

  @override
  void didUpdateWidget(_Carousel old) {
    super.didUpdateWidget(old);
    _syncAmbient();
  }

  void _syncAmbient() {
    if (_page < widget.days.length) {
      final day = widget.days[_page] as Map;
      WidgetsBinding.instance.addPostFrameCallback((_) => setAmbientFrom(day));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _step(int by) => _controller?.animateToPage(_page + by, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isDesktop = context.isDesktop;
    final height = isDesktop ? (size.height * 0.62).clamp(420.0, 700.0) : (size.height * 0.58).clamp(380.0, 620.0);
    final calm = reduceMotion(context);
    if (widget.days.isEmpty) {
      return SizedBox(height: height, child: const PageBody(child: Skeleton(radius: AppTheme.radiusHero)));
    }
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
            child: PageView.builder(
              // Lets the cards' shadows spread beyond the carousel.
              clipBehavior: Clip.none,
              controller: _controller,
              itemCount: widget.days.length,
              onPageChanged: (page) {
                HapticFeedback.selectionClick();
                setState(() => _page = page);
                _syncAmbient();
              },
              itemBuilder: (context, index) => AnimatedBuilder(
                animation: _controller!,
                builder: (context, child) {
                  final position = _controller!.hasClients && _controller!.position.haveDimensions ? _controller!.page ?? _page.toDouble() : _page.toDouble();
                  final distance = (position - index).abs().clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: calm ? 1 : 1 - distance * 0.08,
                    child: Opacity(opacity: 1 - distance * 0.35, child: child),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _HeroCard(day: widget.days[index] as Map),
                ),
              ),
            ),
          ),
          if (isDesktop && _page > 0)
            Positioned(left: 24, child: GlassIconButton(icon: Icons.chevron_left_rounded, tooltip: i10n.nextDay, onPressed: () => _step(-1))),
          if (isDesktop && _page < widget.days.length - 1)
            Positioned(right: 24, child: GlassIconButton(icon: Icons.chevron_right_rounded, tooltip: i10n.previousDay, onPressed: () => _step(1))),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Map day;
  const _HeroCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = day['date'] as String;
    final title = (day['title'] ?? '') as String;
    final credit = (day['copyright'] as String?)?.trim() ?? '';
    final locale = Localizations.localeOf(context).languageCode;
    final isDesktop = context.isDesktop;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusHero),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 14))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusHero),
          child: Semantics(
            button: true,
            label: '$title. ${i10n.readMore}',
            excludeSemantics: true,
            child: Material(
              color: Colors.black,
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                hoverColor: Colors.transparent,
                onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.day(date)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'apod-$date',
                      flightShuttleBuilder: roundedFlight,
                      child: ApodImage(url: (day['url'] ?? '') as String, isVideo: day['media_type'] == 'video', background: Colors.black),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: PhotoGlass(
                        radius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Text(
                          date == todayIso() ? i10n.apodToday : longDate(date, locale),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: PhotoGlass(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: isDesktop ? 30 : 23),
                                  ),
                                  if (credit.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(credit, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.north_east_rounded, color: Colors.black, size: 21),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The same date in earlier years, which APOD's 30-year archive makes possible.
class _OnThisDay extends StatefulWidget {
  final String date;
  const _OnThisDay({super.key, required this.date});

  @override
  State<_OnThisDay> createState() => _OnThisDayState();
}

class _OnThisDayState extends State<_OnThisDay> {
  static const _yearsBack = [1, 2, 3, 5, 10, 15, 20, 25];
  late final Future<List<(int, Map<String, dynamic>)>> _days = _load();

  Future<List<(int, Map<String, dynamic>)>> _load() async {
    final date = DateTime.parse(widget.date);
    final service = NetworkService();
    final results = await Future.wait(_yearsBack.map((years) async {
      final past = DateFormat('yyyy-MM-dd').format(DateTime(date.year - years, date.month, date.day));
      if (!isArchiveDay(past)) return null;
      try {
        return (years, await service.getApod(past));
      } on Exception {
        return null;
      }
    }));
    return results.whereType<(int, Map<String, dynamic>)>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    return FutureBuilder<List<(int, Map<String, dynamic>)>>(
      future: _days,
      builder: (context, snapshot) {
        final days = snapshot.data ?? const [];
        if (snapshot.connectionState == ConnectionState.done && days.isEmpty) return const SizedBox.shrink();
        const cardWidth = 168.0;
        final side = (MediaQuery.of(context).size.width - 1240).clamp(0.0, double.infinity) / 2 + (isDesktop ? 32.0 : 16.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageBody(child: Text(i10n.onThisDay, style: Theme.of(context).textTheme.headlineMedium)),
            const SizedBox(height: 14),
            SizedBox(
              height: cardWidth * 1.3 + 22,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.fromLTRB(side, 0, side, 22),
                  clipBehavior: Clip.none,
                  itemCount: days.isEmpty ? 5 : days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: cardWidth,
                    child: days.isEmpty
                        ? const Skeleton()
                        : Reveal(
                            index: index,
                            child: ApodCard(apod: days[index].$2, aspectRatio: 1 / 1.3, eyebrow: i10n.yearsAgo(days[index].$1)),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
