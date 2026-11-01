import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:nasa_apod/ui/widgets/molecules/download_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/share_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/translate_description.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
import 'package:nasa_apod/utils/image_proxy.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// One day of the archive. Phones: the photograph behind a draggable sheet.
/// Large screens: the photograph and a glass reading panel, floating side by side.
class ApodView extends StatefulWidget {
  final String? date; // yyyy-MM-dd
  const ApodView({super.key, this.date});

  @override
  State<ApodView> createState() => _ApodViewState();
}

class _ApodViewState extends State<ApodView> {
  late final String _date = widget.date ?? todayIso();
  List<String> _favorites = [];
  String? _translated;
  bool _translating = false;
  String? _ambientFor;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ApodBloc>();
    if (bloc.state.date != _date || bloc.state.apodData?['date'] != _date) {
      bloc.add(ChangeDate(_date));
    }
    AuthService().getFavorites().then((favorites) {
      if (mounted) setState(() => _favorites = List<String>.from(favorites));
    });
  }

  Future<void> _toggleFavorite() async {
    final i10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final wasFavorite = _favorites.contains(_date);
    HapticFeedback.lightImpact();
    setState(() => wasFavorite ? _favorites.remove(_date) : _favorites.add(_date));
    if (wasFavorite) {
      await AuthService().removeFavorite(_date);
    } else {
      await AuthService().addFavorite(_date);
    }
    if (mounted) messenger.showSnackBar(SnackBar(content: Text(wasFavorite ? i10n.favoriteRemoved : i10n.favoriteAdded)));
  }

  Future<void> _translate(String explanation, AppLocalizations i10n) async {
    setState(() => _translating = true);
    final translated = await translateDescription(context, explanation, i10n);
    if (mounted) {
      setState(() {
        _translated = translated;
        _translating = false;
      });
    }
  }

  void _openDay(String? date) {
    if (date != null) Navigator.of(context).pushReplacementNamed(AppRoutes.day(date));
  }

  void _back() {
    // A shared link opens this page first, with nothing to go back to.
    final navigator = Navigator.of(context);
    navigator.canPop() ? navigator.pop() : navigator.pushReplacementNamed(AppRoutes.home);
  }

  // Swiping the photograph moves through the archive, as in a photo app.
  void _swipe(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    if (speed.abs() < 200) return;
    _openDay(shiftDay(_date, speed < 0 ? -1 : 1));
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final padding = MediaQuery.of(context).padding;
    final isDesktop = context.isDesktop;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: AppBackground()),
            Positioned.fill(
              child: BlocBuilder<ApodBloc, ApodState>(
                builder: (context, state) {
                  final apod = state.apodData;
                  final ready = state.status == ApodStatus.success && apod != null && apod['date'] == _date;
                  if (ready && _ambientFor != _date) {
                    _ambientFor = _date;
                    WidgetsBinding.instance.addPostFrameCallback((_) => setAmbientFrom(apod));
                  }
                  if (state.status == ApodStatus.failed) {
                    return StateMessage(
                      icon: Icons.cloud_off_rounded,
                      title: i10n.genericError,
                      body: apodErrorText(i10n, state.errorCode),
                      actionLabel: i10n.retry,
                      onAction: () => context.read<ApodBloc>().add(ChangeDate(_date)),
                    );
                  }
                  if (!ready) return _Loading(wide: isDesktop);
                  return isDesktop ? _wide(apod, i10n) : _phone(apod, i10n);
                },
              ),
            ),
            Positioned(
              top: padding.top + (isDesktop ? 28 : 12),
              left: isDesktop ? 28 : 12,
              child: GlassIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: _back,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phone(Map<String, dynamic> apod, AppLocalizations i10n) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.6,
          child: GestureDetector(onHorizontalDragEnd: _swipe, child: _Stage(apod: apod, date: _date, fit: BoxFit.cover, radius: 0)),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.42,
          maxChildSize: 0.94,
          snap: true,
          builder: (context, controller) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
            child: DecoratedBox(
              decoration: BoxDecoration(color: scheme.surface),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(22, 10, 22, padding.bottom + 104),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(color: scheme.outline, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  ..._story(apod, i10n, titleSize: 28),
                ],
              ),
            ),
          ),
        ),
        // Text fades out beneath the dock instead of running behind it.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: padding.bottom + 110,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0, 0.55], colors: [scheme.surface.withValues(alpha: 0), scheme.surface]),
              ),
            ),
          ),
        ),
        Positioned(left: 0, right: 0, bottom: padding.bottom + 16, child: Center(child: _actionDock(apod, i10n))),
      ],
    );
  }

  Widget _wide(Map<String, dynamic> apod, AppLocalizations i10n) {
    final padding = MediaQuery.of(context).padding;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, padding.top + 16, 16, padding.bottom + 16),
      child: Row(
        children: [
          Expanded(child: GestureDetector(onHorizontalDragEnd: _swipe, child: _Stage(apod: apod, date: _date, fit: BoxFit.contain, radius: AppTheme.radiusHero, backdrop: Colors.transparent))),
          const SizedBox(width: 16),
          SizedBox(
            width: 460,
            child: Glass(
              radius: AppTheme.radiusHero,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(32, 36, 32, 24),
                      children: _story(apod, i10n, titleSize: 34),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), child: _actionDock(apod, i10n)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The day's actions, always within reach.
  Widget _actionDock(Map<String, dynamic> apod, AppLocalizations i10n) {
    final scheme = Theme.of(context).colorScheme;
    final isFavorite = _favorites.contains(_date);
    final isImage = apod['media_type'] == 'image';
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 26, offset: Offset(0, 10))],
      ),
      child: Glass(
        radius: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isFavorite ? i10n.removeFromFavorites : i10n.addToFavorites,
                onPressed: _toggleFavorite,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, key: ValueKey(isFavorite), color: isFavorite ? scheme.primary : null),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(tooltip: i10n.share, onPressed: () => _share(apod), icon: const Icon(Icons.ios_share_rounded, size: 21)),
              if (isImage) ...[
                const SizedBox(width: 4),
                IconButton(tooltip: i10n.downloadApod, onPressed: () => _download(apod), icon: const Icon(Icons.download_rounded, size: 22)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _share(Map<String, dynamic> apod) => shareApod(context, title: (apod['title'] ?? '') as String, date: _date, imageUrl: (apod['url'] ?? '') as String, credit: apod['copyright'] as String?);
  void _download(Map<String, dynamic> apod) => saveNetworkImage(context, (apod['url'] ?? '') as String, (apod['title'] ?? '') as String);

  List<Widget> _story(Map<String, dynamic> apod, AppLocalizations i10n, {required double titleSize}) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final credit = (apod['copyright'] as String?)?.replaceAll('\n', ' ').trim() ?? '';
    final explanation = (apod['explanation'] ?? '') as String;
    final previous = shiftDay(_date, -1);
    final next = shiftDay(_date, 1);
    return [
      Text(longDate(_date, locale), style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontSize: 13)),
      const SizedBox(height: 8),
      Text((apod['title'] ?? '') as String, style: theme.textTheme.displaySmall?.copyWith(fontSize: titleSize)),
      const SizedBox(height: 10),
      if (credit.isNotEmpty) ...[
        Text('${i10n.imageCredit}: $credit', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
      ],
      SelectableText(_translated ?? explanation, style: theme.textTheme.bodyLarge),
      // NASA writes in English, so translation is only offered to other readers.
      if (locale != 'en' && _translated == null) ...[
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _translating ? null : () => _translate(explanation, i10n),
            icon: _translating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.translate_rounded, size: 18),
            label: Text(_translating ? i10n.translating : i10n.translate),
          ),
        ),
      ],
      const SizedBox(height: 24),
      Row(
        children: [
          if (previous != null)
            Expanded(child: OutlinedButton.icon(onPressed: () => _openDay(previous), icon: const Icon(Icons.chevron_left_rounded), label: Text(i10n.previousDay, maxLines: 1, overflow: TextOverflow.ellipsis))),
          if (previous != null && next != null) const SizedBox(width: 8),
          if (next != null)
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: OutlinedButton.icon(onPressed: () => _openDay(next), icon: const Icon(Icons.chevron_left_rounded), label: Text(i10n.nextDay, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ),
            ),
        ],
      ),
    ];
  }
}

/// The shape of the page while it loads.
class _Loading extends StatelessWidget {
  final bool wide;
  const _Loading({required this.wide});

  static const _story = Padding(
    padding: EdgeInsets.fromLTRB(28, 36, 28, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Skeleton(height: 12, radius: 6)),
        SizedBox(height: 16),
        Skeleton(height: 36, radius: 12),
        SizedBox(height: 24),
        Skeleton(height: 12, radius: 6),
        SizedBox(height: 10),
        Skeleton(height: 12, radius: 6),
        SizedBox(height: 10),
        SizedBox(width: 200, child: Skeleton(height: 12, radius: 6)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (wide) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(children: [Expanded(child: Skeleton(radius: AppTheme.radiusHero)), SizedBox(width: 476, child: _story)]),
      );
    }
    return const Column(children: [Expanded(flex: 3, child: Skeleton(radius: 0)), Expanded(flex: 2, child: _story)]);
  }
}

/// The photograph. Tapping it opens the full, uncropped view.
class _Stage extends StatelessWidget {
  final Map<String, dynamic> apod;
  final String date;
  final BoxFit fit;
  final double radius;
  final Color backdrop;
  const _Stage({required this.apod, required this.date, required this.fit, required this.radius, this.backdrop = Colors.black});

  void _openFullScreen(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final url = proxiedImageUrl((apod['hdurl'] ?? apod['url']) as String);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 6,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  errorBuilder: (context, error, stack) =>
                      Center(child: Text(i10n.imageLoadError, style: const TextStyle(color: Colors.white))),
                ),
              ),
            ),
            if (apod['copyright'] != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('${i10n.imageCredit}: ${apod['copyright']}', style: const TextStyle(color: Colors.white, fontSize: 12, shadows: [Shadow(blurRadius: 6)])),
                  ),
                ),
              ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GlassIconButton(icon: Icons.close_rounded, tooltip: i10n.close, onPressed: () => Navigator.of(context).pop()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final Widget child;
    if (apod['media_type'] != 'image') {
      child = ColoredBox(
        color: Colors.black,
        child: Center(child: AspectRatio(aspectRatio: 16 / 9, child: _ApodVideo(url: apod['url'] as String))),
      );
    } else {
      child = ColoredBox(
        color: backdrop,
        child: Semantics(
          button: true,
          label: i10n.viewFullScreen,
          child: InkWell(
            onTap: () => _openFullScreen(context),
            mouseCursor: SystemMouseCursors.zoomIn,
            child: Hero(
              tag: 'apod-$date',
              flightShuttleBuilder: roundedFlight,
              child: ApodImage(url: apod['url'] as String, fit: fit, background: backdrop),
            ),
          ),
        ),
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

class _ApodVideo extends StatefulWidget {
  final String url;
  const _ApodVideo({required this.url});

  @override
  State<_ApodVideo> createState() => _ApodVideoState();
}

class _ApodVideoState extends State<_ApodVideo> {
  late final String _url = widget.url;
  YoutubePlayerController? _ytController;

  String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      // watch?v=ID
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      // embed/ID
      final idx = uri.pathSegments.indexOf('embed');
      if (idx != -1 && uri.pathSegments.length > idx + 1) {
        return uri.pathSegments[idx + 1];
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final ytId = _extractYouTubeId(_url);
    if (ytId != null) {
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: ytId,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ytController != null) {
      return YoutubePlayer(controller: _ytController!);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: FilledButton.icon(
            onPressed: () async {
              final uri = Uri.tryParse(_url);
              if (uri != null) {
                await ul.launchUrl(uri,
                    mode: ul.LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(AppLocalizations.of(context)!.openVideo),
          ),
        ),
      ],
    );
  }
}
