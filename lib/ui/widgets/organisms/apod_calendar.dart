import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nasa_apod/data/nasa.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
import 'package:nasa_apod/utils/image_proxy.dart';

/// Appod's own calendar, as a sheet: every day shows its picture, so the
/// archive reads like a photo album, and the chosen day is previewed before
/// the reader commits to it. Resolves to the chosen day, or null.
Future<DateTime?> showApodCalendar(BuildContext context, {required DateTime initial, bool startOnYears = false, String? title}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (_) => _CalendarSheet(initial: initial, startOnYears: startOnYears, title: title),
  );
}

enum _Mode { days, years, months }

final _isoFormat = DateFormat('yyyy-MM-dd');
const _ease = Cubic(0.23, 1, 0.32, 1);

class _CalendarSheet extends StatefulWidget {
  final DateTime initial;
  final bool startOnYears;
  final String? title;
  const _CalendarSheet({required this.initial, required this.startOnYears, this.title});

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  // Months already fetched, kept while the app runs: 'yyyy-MM' -> date -> day.
  static final _months = <String, Map<String, Map<String, dynamic>>>{};
  static final _loading = <String>{};
  final _service = NetworkService();
  final _random = Random();

  late final DateTime _first = DateTime(firstApodDate.year, firstApodDate.month);
  late final DateTime _today = DateTime.parse(todayIso());
  late final int _monthCount = _monthIndex(_today) + 1;
  late DateTime _selected;
  late int _page;
  late PageController _pages;
  late _Mode _mode;
  int _year = 2000;

  int _monthIndex(DateTime d) => (d.year - _first.year) * 12 + d.month - _first.month;
  DateTime _monthAt(int i) => DateTime(_first.year, _first.month + i);
  String _monthKey(DateTime m) => DateFormat('yyyy-MM').format(m);
  bool _inArchive(DateTime d) => !d.isBefore(firstApodDate) && !d.isAfter(_today);

  DateTime _clamp(DateTime d) => d.isBefore(firstApodDate) ? firstApodDate : (d.isAfter(_today) ? _today : d);

  @override
  void initState() {
    super.initState();
    _selected = _clamp(DateTime(widget.initial.year, widget.initial.month, widget.initial.day));
    _page = _monthIndex(_selected);
    _pages = PageController(initialPage: _page);
    _mode = widget.startOnYears ? _Mode.years : _Mode.days;
    _year = _selected.year;
    _load(_page);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Fetches this month and its neighbors, so a swipe lands on pictures.
  Future<void> _load(int index) async {
    for (final i in [index, index - 1, index + 1]) {
      if (i < 0 || i >= _monthCount) continue;
      final month = _monthAt(i);
      final key = _monthKey(month);
      if (_months.containsKey(key) || _loading.contains(key)) continue;
      _loading.add(key);
      final last = DateTime(month.year, month.month + 1, 0);
      try {
        final days = await _service.getApodRange(month, last.isAfter(_today) ? _today : last);
        _months[key] = {
          for (final day in days)
            if (day is Map && day['date'] is String) day['date'] as String: Map<String, dynamic>.from(day),
        };
      } on Exception {
        // Without pictures the calendar still works; the numbers stay plain.
      } finally {
        _loading.remove(key);
      }
      if (mounted) setState(() {});
    }
  }

  Map<String, dynamic>? _dayData(DateTime d) => _months[_monthKey(d)]?[_isoFormat.format(d)];

  void _goTo(DateTime day) {
    final target = _clamp(day);
    HapticFeedback.selectionClick();
    final page = _monthIndex(target);
    setState(() {
      _selected = target;
      _mode = _Mode.days;
    });
    _showPage(page);
  }

  void _showPage(int page) {
    if (!_pages.hasClients) {
      _pages.dispose();
      _pages = PageController(initialPage: page);
      setState(() => _page = page);
      _load(page);
      return;
    }
    if (reduceMotion(context) || (page - _page).abs() > 2) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(page, duration: const Duration(milliseconds: 320), curve: _ease);
    }
  }

  void _setMode(_Mode mode) {
    HapticFeedback.selectionClick();
    if (mode == _Mode.days && _mode != _Mode.days) {
      // The month grid was off screen; rebuild it on the current month.
      _pages.dispose();
      _pages = PageController(initialPage: _page);
    }
    setState(() => _mode = mode);
  }

  void _pickYear(int year) {
    HapticFeedback.selectionClick();
    setState(() {
      _year = year;
      _mode = _Mode.months;
    });
  }

  void _pickMonth(int month) {
    final days = DateTime(_year, month + 1, 0).day;
    final day = _clamp(DateTime(_year, month, min(_selected.day, days)));
    _page = _monthIndex(day);
    _selected = day;
    _load(_page);
    _setMode(_Mode.days);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF12151B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
        border: Border(top: BorderSide(color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.08))),
      ),
      padding: EdgeInsets.fromLTRB(18, 10, 18, 16 + media.padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: scheme.onSurface.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
            ),
          ),
          const SizedBox(height: 14),
          _header(context),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              const gap = 6.0;
              final cell = (box.maxWidth - 6 * gap) / 7;
              final height = 24 + 6 * cell + 5 * gap;
              return SizedBox(
                height: height,
                child: AnimatedSwitcher(
                  duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 220),
                  switchInCurve: _ease,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(animation), child: child),
                  ),
                  child: switch (_mode) {
                    _Mode.days => KeyedSubtree(key: const ValueKey('days'), child: _daysView(context, cell, gap)),
                    _Mode.years => KeyedSubtree(key: const ValueKey('years'), child: _yearsView(context, height)),
                    _Mode.months => KeyedSubtree(key: ValueKey('months-$_year'), child: _monthsView(context)),
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _footer(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final month = _monthAt(_page);
    final label = switch (_mode) {
      _Mode.days => toBeginningOfSentenceCase(DateFormat.MMMM(locale).format(month)),
      _Mode.years => i10n.chooseYear,
      _Mode.months => '$_year',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title ?? i10n.chooseDate, style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        SizedBox(
          height: 44,
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    button: true,
                    label: _mode == _Mode.days ? '$label ${month.year}. ${i10n.chooseYear}' : label,
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMark),
                      onTap: () => _setMode(_mode == _Mode.days ? _Mode.years : _Mode.days),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(text: label),
                                  // The year sits beside the month, quieter, so both fit.
                                  if (_mode == _Mode.days) TextSpan(text: ' ${month.year}', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                                ]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontFeatures: AppTheme.tabular),
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: _mode == _Mode.days ? 0 : 0.5,
                              duration: const Duration(milliseconds: 220),
                              curve: _ease,
                              child: Icon(Icons.expand_more_rounded, color: scheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_mode == _Mode.days) ...[
                _RoundButton(icon: Icons.chevron_left_rounded, tooltip: i10n.previousMonth, onTap: _page > 0 ? () => _showPage(_page - 1) : null),
                const SizedBox(width: 8),
                _RoundButton(icon: Icons.chevron_right_rounded, tooltip: i10n.nextMonth, onTap: _page < _monthCount - 1 ? () => _showPage(_page + 1) : null),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        // The shortcuts keep their room in every view, so the sheet never jumps.
        SizedBox(
          height: 34,
          child: _mode != _Mode.days
              ? null
              : ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _QuickChip(icon: Icons.today_rounded, label: i10n.today, onTap: () => _goTo(_today)),
                    _QuickChip(icon: Icons.history_rounded, label: i10n.oneYearAgo, onTap: () => _goTo(DateTime(_today.year - 1, _today.month, _today.day))),
                    _QuickChip(
                      icon: Icons.casino_outlined,
                      label: i10n.randomDay,
                      onTap: () => _goTo(firstApodDate.add(Duration(days: _random.nextInt(_today.difference(firstApodDate).inDays + 1)))),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _daysView(BuildContext context, double cell, double gap) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final material = MaterialLocalizations.of(context);
    final firstWeekday = material.firstDayOfWeekIndex; // 0 = Sunday
    final names = [for (var i = 0; i < 7; i++) material.narrowWeekdays[(firstWeekday + i) % 7]];
    return Column(
      children: [
        SizedBox(
          height: 24,
          child: Row(
            children: [
              for (final name in names) Expanded(child: Center(child: Text(name, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)))),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pages,
            itemCount: _monthCount,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _page = i);
              _load(i);
            },
            itemBuilder: (context, i) => _monthGrid(context, _monthAt(i), cell, gap, firstWeekday),
          ),
        ),
      ],
    );
  }

  Widget _monthGrid(BuildContext context, DateTime month, double cell, double gap, int firstWeekday) {
    final offset = (month.weekday % 7 - firstWeekday + 7) % 7;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final locale = Localizations.localeOf(context).languageCode;
    final todayIso = _isoFormat.format(_today);
    final selectedIso = _isoFormat.format(_selected);
    return Column(
      children: [
        for (var row = 0; row < 6; row++) ...[
          if (row > 0) SizedBox(height: gap),
          SizedBox(
            height: cell,
            child: Row(
              children: [
                for (var col = 0; col < 7; col++) ...[
                  if (col > 0) SizedBox(width: gap),
                  SizedBox(
                    width: cell,
                    child: () {
                      final n = row * 7 + col - offset + 1;
                      if (n < 1 || n > days) return const SizedBox.shrink();
                      final date = DateTime(month.year, month.month, n);
                      final iso = _isoFormat.format(date);
                      return _DayCell(
                        day: n,
                        label: longDate(iso, locale),
                        data: _dayData(date),
                        enabled: _inArchive(date),
                        selected: iso == selectedIso,
                        today: iso == todayIso,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = date);
                        },
                      );
                    }(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _yearsView(BuildContext context, double height) {
    final years = [for (var y = firstApodDate.year; y <= _today.year; y++) y];
    const rowHeight = 52.0;
    final index = years.indexOf(_year);
    // Opens with the current year in view, roughly in the middle.
    final controller = ScrollController(initialScrollOffset: max(0, (index ~/ 4) * rowHeight - height / 2 + rowHeight));
    return GridView.builder(
      controller: controller,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisExtent: rowHeight - 8, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemCount: years.length,
      itemBuilder: (context, i) => _PickChip(label: '${years[i]}', selected: years[i] == _selected.year, onTap: () => _pickYear(years[i])),
    );
  }

  Widget _monthsView(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 56, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: 12,
      itemBuilder: (context, i) {
        final month = DateTime(_year, i + 1);
        final enabled = !DateTime(_year, i + 2, 0).isBefore(firstApodDate) && !month.isAfter(_today);
        return _PickChip(
          label: toBeginningOfSentenceCase(DateFormat.MMMM(locale).format(month)),
          selected: _year == _selected.year && i + 1 == _selected.month,
          onTap: enabled ? () => _pickMonth(i + 1) : null,
        );
      },
    );
  }

  Widget _footer(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final data = _dayData(_selected);
    final thumb = _thumbUrl(data, 200);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMark),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: thumb == null
                      ? ColoredBox(color: scheme.onSurface.withValues(alpha: 0.06), child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant))
                      : CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover, memCacheWidth: 200, fadeInDuration: const Duration(milliseconds: 200)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(shortDate(_isoFormat.format(_selected), locale),
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary, fontFeatures: AppTheme.tabular)),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        '${data?['title'] ?? ''}',
                        key: ValueKey(data?['title']),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop(_selected);
          },
          style: FilledButton.styleFrom(minimumSize: const Size(0, 52), padding: const EdgeInsets.symmetric(horizontal: 22)),
          child: Text(i10n.seeThisDay, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

String? _thumbUrl(Map<String, dynamic>? data, int width) {
  if (data == null || data['media_type'] != 'image' || data['url'] is! String) return null;
  final url = apodImageUrl(data['url'] as String);
  return url.contains('w=1280') ? url.replaceFirst('w=1280', 'w=$width') : url;
}

class _DayCell extends StatelessWidget {
  final int day;
  final String label;
  final Map<String, dynamic>? data;
  final bool enabled;
  final bool selected;
  final bool today;
  final VoidCallback onTap;
  const _DayCell({required this.day, required this.label, required this.data, required this.enabled, required this.selected, required this.today, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final thumb = enabled ? _thumbUrl(data, 160) : null;
    final number = Text(
      '$day',
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: selected || today ? FontWeight.w800 : FontWeight.w600,
        fontFeatures: AppTheme.tabular,
        color: thumb != null ? Colors.white : (enabled ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.22)),
        shadows: thumb != null ? const [Shadow(color: Colors.black87, blurRadius: 6)] : null,
      ),
    );
    return Semantics(
      button: enabled,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: _ease,
          padding: EdgeInsets.all(selected ? 2.5 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: scheme.primary, width: 2.5)
                : today
                    ? Border.all(color: scheme.onSurface.withValues(alpha: 0.55), width: 1.5)
                    : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(selected ? 7 : 10.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: enabled ? scheme.onSurface.withValues(alpha: 0.05) : Colors.transparent),
                if (thumb != null) ...[
                  CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover, memCacheWidth: 160, fadeInDuration: const Duration(milliseconds: 250), errorWidget: (_, __, ___) => const SizedBox.shrink()),
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x14000000), Color(0x8C000000)])),
                  ),
                ],
                Center(child: number),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  const _RoundButton({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: tooltip,
      excludeSemantics: true,
      child: Material(
        color: scheme.onSurface.withValues(alpha: 0.06),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: SizedBox(width: 44, height: 44, child: Icon(icon, color: onTap == null ? scheme.onSurface.withValues(alpha: 0.25) : scheme.onSurface)),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: scheme.primary.withValues(alpha: 0.12),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(label, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _PickChip({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    return Material(
      color: selected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppTheme.radiusControl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusControl),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: AppTheme.tabular,
              color: selected ? scheme.onPrimary : (enabled ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.25)),
            ),
          ),
        ),
      ),
    );
  }
}
