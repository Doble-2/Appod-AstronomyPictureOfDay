import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';
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
    final top = MediaQuery.of(context).padding.top + Layout.headerHeight;
    return BlocBuilder<ApodBloc, ApodState>(
      builder: (context, state) {
        if (state.status == ApodStatus.failed) {
          return Padding(
            padding: EdgeInsets.only(top: top + 8),
            child: PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DayStrip(date: state.date),
                  StateMessage(
                    icon: Icons.cloud_off_rounded,
                    title: i10n.genericError,
                    body: apodErrorText(i10n, state.errorCode),
                    actionLabel: i10n.retry,
                    onAction: () => context.read<ApodBloc>().add(RefreshData()),
                  ),
                ],
              ),
            ),
          );
        }
        final others = state.multipleApodData.where((a) => a['url'] != null).toList();
        final loadingOthers = state.multiplestatus == ApodStatus.loading && others.isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Hero(apod: state.apodData, date: state.date),
            PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _DayStrip(date: state.date),
                  const SizedBox(height: 36),
                  Text(i10n.previousDays, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  ApodGrid(
                    children: loadingOthers
                        ? [for (var i = 0; i < 8; i++) const AspectRatio(aspectRatio: 4 / 3, child: Skeleton())]
                        : [for (final apod in others) ApodCard(key: ValueKey(apod['date']), apod: apod)],
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

/// The picture of the day, edge to edge. Swipe to move between days.
class _Hero extends StatelessWidget {
  final Map<String, dynamic>? apod;
  final String date;
  const _Hero({required this.apod, required this.date});

  void _go(BuildContext context, int days) {
    final target = shiftDay(date, days);
    if (target == null) return;
    HapticFeedback.selectionClick();
    context.read<ApodBloc>().add(ChangeDate(target));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isDesktop = context.isDesktop;
    final height = isDesktop ? (size.height * 0.74).clamp(460.0, 800.0) : (size.height * 0.62).clamp(380.0, 620.0);
    final data = apod;
    if (data == null) return SizedBox(height: height, width: double.infinity, child: const Skeleton(radius: 0));
    final shown = data['date'] as String;
    final locale = Localizations.localeOf(context).languageCode;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final speed = details.primaryVelocity ?? 0;
              if (speed.abs() > 200) _go(context, speed < 0 ? -1 : 1);
            },
            child: Semantics(
              button: true,
              label: '${data['title']}. ${i10n.readMore}',
              excludeSemantics: true,
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                hoverColor: Colors.transparent,
                onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.day(shown)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedSwitcher(
                      duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 500),
                      child: Hero(
                        key: ValueKey(shown),
                        tag: 'apod-$shown',
                        child: _SettlingImage(url: (data['url'] ?? '') as String, isVideo: data['media_type'] == 'video'),
                      ),
                    ),
                    // Darkens only the edges, so the header and title stay legible.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 0.18, 0.55, 1],
                          colors: [Color(0x8C000000), Colors.transparent, Colors.transparent, Color(0xD9000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: isDesktop ? 44 : 24,
            child: IgnorePointer(
              child: PageBody(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: AnimatedSwitcher(
                    duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(animation), child: child),
                    ),
                    // Only the new text is shown, so two titles never overlap.
                    layoutBuilder: (current, previous) => current ?? const SizedBox.shrink(),
                    child: Column(
                      key: ValueKey(shown),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          shown == todayIso() ? '${i10n.apodToday} · ${longDate(shown, locale)}' : longDate(shown, locale),
                          style: theme.textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (data['title'] ?? '') as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: isDesktop ? 44 : 28),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(height: 10),
                          Text(
                            (data['explanation'] ?? '') as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),
          if (isDesktop) ...[
            if (shiftDay(date, -1) != null)
              Positioned(left: 24, top: 0, bottom: 0, child: Center(child: GlassIconButton(icon: Icons.chevron_left_rounded, tooltip: i10n.previousDay, onPressed: () => _go(context, -1)))),
            if (shiftDay(date, 1) != null)
              Positioned(right: 24, top: 0, bottom: 0, child: Center(child: GlassIconButton(icon: Icons.chevron_right_rounded, tooltip: i10n.nextDay, onPressed: () => _go(context, 1)))),
          ],
        ],
      ),
    );
  }
}

/// The photograph eases out of a slight zoom when it arrives.
class _SettlingImage extends StatelessWidget {
  final String url;
  final bool isVideo;
  const _SettlingImage({required this.url, required this.isVideo});

  @override
  Widget build(BuildContext context) {
    final image = ApodImage(url: url, isVideo: isVideo);
    if (reduceMotion(context)) return image;
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.05, end: 1),
        duration: const Duration(milliseconds: 1600),
        curve: Curves.easeOutCubic,
        child: image,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      ),
    );
  }
}

/// A quiet row of days to tap through, under the current month, with a
/// calendar for jumping further back.
class _DayStrip extends StatefulWidget {
  final String date;
  const _DayStrip({required this.date});

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  static const _extent = 52.0;
  static const _count = 60;
  final _controller = ScrollController();
  bool _needsCenter = true;

  // The strip reaches back from today, or is centered on an older day.
  List<String> get _days {
    var anchor = shiftDay(widget.date, 15) ?? todayIso();
    final difference = DateTime.parse(todayIso()).difference(DateTime.parse(widget.date)).inDays;
    if (difference < 30) anchor = todayIso();
    return [
      for (var i = 0; i < _count; i++)
        if (shiftDay(anchor, -i) != null) shiftDay(anchor, -i)!,
    ];
  }

  void _center() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Under another page the strip has no size yet; it centers once it has one.
      if (!_controller.hasClients || !_controller.position.hasViewportDimension) return;
      _needsCenter = false;
      final index = _days.indexOf(widget.date);
      if (index < 0) return;
      final target = index * _extent - _controller.position.viewportDimension / 2 + _extent / 2;
      _controller.animateTo(target.clamp(0, _controller.position.maxScrollExtent), duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    });
  }

  @override
  void initState() {
    super.initState();
    _center();
  }

  @override
  void didUpdateWidget(_DayStrip old) {
    super.didUpdateWidget(old);
    if (old.date != widget.date) _center();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final bloc = context.read<ApodBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.date) ?? DateTime.now(),
      firstDate: firstApodDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) bloc.add(ChangeDate(DateFormat('yyyy-MM-dd').format(picked)));
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final days = _days;
    final month = toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(DateTime.parse(widget.date)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(month, style: theme.textTheme.titleLarge)),
            IconButton(tooltip: i10n.chooseDate, onPressed: _pick, icon: const Icon(Icons.calendar_month_outlined, size: 22)),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 68,
          child: ShaderMask(
            // Days fade out at the edge instead of being cut off.
            shaderCallback: (rect) => const LinearGradient(colors: [Colors.white, Colors.white, Colors.transparent], stops: [0, 0.92, 1]).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (_) {
                  if (_needsCenter) _center();
                  return false;
                },
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemExtent: _extent,
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final parsed = DateTime.parse(day);
                    final selected = day == widget.date;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: longDate(day, locale),
                        excludeSemantics: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.read<ApodBloc>().add(ChangeDate(day));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: selected ? scheme.primary : Colors.transparent),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat.E(locale).format(parsed), style: TextStyle(color: selected ? scheme.onPrimary : scheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text('${parsed.day}', style: TextStyle(color: selected ? scheme.onPrimary : scheme.onSurface, fontSize: 17, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])),
                                const SizedBox(height: 3),
                                // A dot marks today, wherever the reader is in the strip.
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: day != todayIso() ? Colors.transparent : (selected ? scheme.onPrimary : scheme.primary)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
