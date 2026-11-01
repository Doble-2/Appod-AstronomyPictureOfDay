import 'dart:math';

import 'package:flutter/foundation.dart';
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
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scroll = ScrollController();
  final _random = Random();
  final _service = NetworkService();
  // The endless wall: each batch is one random stretch of the 30-year archive.
  final _batches = <List<dynamic>>[];
  final _seen = <String>{};
  bool _loadingArchive = false;
  bool _archiveFailed = false;

  @override
  void initState() {
    super.initState();
    // Coming back to this tab keeps the day the reader was looking at.
    final bloc = context.read<ApodBloc>();
    if (bloc.state.apodData == null) bloc.add(RefreshData());
    _scroll.addListener(_loadIfNearEnd);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _loadIfNearEnd() {
    // Beneath another page the list has not been measured, and needs nothing yet.
    if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) return;
    if (_scroll.position.extentAfter < 900) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingArchive || _archiveFailed) return;
    setState(() => _loadingArchive = true);
    var failed = false;
    List<dynamic> fresh = const [];
    // A random stretch can come back empty, so try a few before giving up.
    for (var attempt = 0; attempt < 3 && fresh.isEmpty && !failed; attempt++) {
      final (start, end) = randomArchiveWindow(_random, DateTime.now());
      try {
        final days = await _service.getApodRange(start, end);
        fresh = days.where((day) => day['url'] != null && !_seen.contains(day['date'])).toList()..shuffle(_random);
      } on Exception {
        failed = true;
      }
    }
    if (!mounted) return;
    setState(() {
      _loadingArchive = false;
      _archiveFailed = failed;
      if (fresh.isNotEmpty) {
        _seen.addAll(fresh.map((day) => day['date'] as String));
        _batches.add(fresh);
      }
    });
    // A tall screen may still have room after the first batch.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNearEnd());
  }

  void _retryArchive() {
    setState(() => _archiveFailed = false);
    _loadMore();
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
        final others = state.multipleApodData.where((a) => a['url'] != null);
        final current = state.apodData;
        final top = <Widget>[
          if (!context.isDesktop) const PageBody(child: Padding(padding: EdgeInsets.only(bottom: 14), child: AppodLogo())),
          PageBody(child: _Heading(date: state.date)),
          const SizedBox(height: 18),
          if (state.status == ApodStatus.failed)
            PageBody(
              child: StateMessage(
                icon: Icons.cloud_off_rounded,
                title: i10n.genericError,
                body: apodErrorText(i10n, state.errorCode),
                actionLabel: i10n.retry,
                onAction: () => context.read<ApodBloc>().add(RefreshData()),
              ),
            )
          else
            _Carousel(key: ValueKey(state.date), days: [if (current != null) current, ...others], date: state.date),
          const _GetAppNotice(),
          const SizedBox(height: 30),
          _OnThisDay(key: ValueKey('otd-${state.date}'), date: state.date),
          const SizedBox(height: 30),
          PageBody(child: Text(i10n.fromTheArchive, style: theme.textTheme.headlineMedium)),
          const SizedBox(height: 14),
        ];
        return ListView.builder(
          controller: _scroll,
          padding: EdgeInsets.only(top: Layout.topInset(context), bottom: Layout.bottomInset(context)),
          itemCount: top.length + _batches.length + 1,
          itemBuilder: (context, index) {
            if (index < top.length) return top[index];
            final batch = index - top.length;
            if (batch < _batches.length) {
              return PageBody(
                child: ApodMasonry<dynamic>(
                  items: _batches[batch],
                  builder: (apod, shape) => ApodCard(apod: apod as Map, aspectRatio: shape),
                ),
              );
            }
            if (_archiveFailed) {
              return PageBody(
                child: StateMessage(
                  icon: Icons.cloud_off_rounded,
                  title: i10n.genericError,
                  body: i10n.errorConnection,
                  actionLabel: i10n.retry,
                  onAction: _retryArchive,
                ),
              );
            }
            if (_batches.isEmpty) {
              return PageBody(
                child: ApodMasonry<int>(
                  items: List.generate(8, (i) => i),
                  builder: (_, shape) => AspectRatio(aspectRatio: shape, child: const Skeleton()),
                ),
              );
            }
            return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
          },
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
              Text(toBeginningOfSentenceCase(DateFormat.MMMEd(locale).format(parsed)), style: theme.textTheme.labelMedium?.copyWith(fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                isToday ? i10n.today : shortDate(date, locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.displayLarge,
              ),
            ],
          ),
        ),
        if (!isToday)
          IconButton(
            tooltip: i10n.backToToday,
            onPressed: () => context.read<ApodBloc>().add(ChangeDate(todayIso())),
            icon: const Icon(Icons.today_rounded),
          ),
        IconButton(tooltip: i10n.chooseDate, onPressed: () => _pick(context), icon: const Icon(Icons.calendar_month_outlined)),
      ],
    );
  }
}

/// Big cards aligned to the page, with the neighbors peeking in. The one in
/// focus colors the screen.
class _Carousel extends StatefulWidget {
  final List<dynamic> days;
  final String date;
  const _Carousel({super.key, required this.days, required this.date});

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  static const _gap = 6.0;
  PageController? _controller;
  int _page = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    // A card as wide as the page column, so its edges line up with the heading.
    final content = min(width, 1240.0) - 2 * (context.isDesktop ? 32 : 16);
    final fraction = (content + 2 * _gap) / width;
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
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = context.isDesktop;
    final height = isDesktop ? (size.height * 0.62).clamp(420.0, 700.0) : (size.height * 0.56).clamp(380.0, 600.0);
    final calm = reduceMotion(context);
    if (widget.days.isEmpty) {
      return SizedBox(height: height, child: const PageBody(child: Skeleton(radius: AppTheme.radiusHero)));
    }
    return Column(
      children: [
        SizedBox(
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
                      return Transform.scale(scale: calm ? 1 : 1 - distance * 0.05, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _gap),
                      child: _HeroCard(day: widget.days[index] as Map),
                    ),
                  ),
                ),
              ),
              if (isDesktop && _page > 0)
                Positioned(left: 44, child: GlassIconButton(icon: Icons.chevron_left_rounded, tooltip: i10n.nextDay, onPressed: () => _step(-1))),
              if (isDesktop && _page < widget.days.length - 1)
                Positioned(right: 44, child: GlassIconButton(icon: Icons.chevron_right_rounded, tooltip: i10n.previousDay, onPressed: () => _step(1))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.days.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: i == _page ? scheme.primary : scheme.onSurface.withValues(alpha: 0.25)),
                ),
            ],
          ),
        ),
      ],
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusHero),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 28, offset: Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusHero),
        child: Semantics(
          button: true,
          label: '$title. ${i10n.readMore}',
          excludeSemantics: true,
          onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.day(date)),
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
                  const DecoratedBox(decoration: BoxDecoration(gradient: heroScrim)),
                  Positioned(
                    left: isDesktop ? 28 : 18,
                    right: isDesktop ? 28 : 18,
                    bottom: isDesktop ? 26 : 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          date == todayIso() ? i10n.apodToday : shortDate(date, locale),
                          style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: isDesktop ? 42 : 27),
                        ),
                        if (credit.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(credit, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                ],
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

/// On the web in an Android phone, a quiet offer of the app, once.
class _GetAppNotice extends StatefulWidget {
  const _GetAppNotice();

  @override
  State<_GetAppNotice> createState() => _GetAppNoticeState();
}

class _GetAppNoticeState extends State<_GetAppNotice> {
  static const _key = 'getAppNoticeDismissed';
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    SharedPreferences.getInstance().then((prefs) {
      if (mounted && prefs.getBool(_key) != true) setState(() => _visible = true);
    });
  }

  Future<void> _dismiss() async {
    setState(() => _visible = false);
    (await SharedPreferences.getInstance()).setBool(_key, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final i10n = AppLocalizations.of(context)!;
    return PageBody(
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Row(
          children: [
            Expanded(child: Text(i10n.getAppTitle, style: Theme.of(context).textTheme.bodyMedium)),
            TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.getApp), child: Text(i10n.getApp)),
            IconButton(tooltip: i10n.close, onPressed: _dismiss, icon: const Icon(Icons.close_rounded, size: 18)),
          ],
        ),
      ),
    );
  }
}
