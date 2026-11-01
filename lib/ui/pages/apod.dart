import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/data/nasa.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
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

/// Reading the archive: days are pages that follow the finger. Swiping left
/// goes to the day before. Opening a day never changes what home is showing.
class ApodView extends StatefulWidget {
  final String? date; // yyyy-MM-dd
  const ApodView({super.key, this.date});

  @override
  State<ApodView> createState() => _ApodViewState();
}

class _ApodViewState extends State<ApodView> {
  final _today = DateTime.parse(todayIso());
  final _service = NetworkService();
  final _focus = FocusNode();
  final String? _ambientBefore = ambientPicture.value;
  late final int _dayCount = _today.difference(firstApodDate).inDays + 1;
  late final PageController _pages = PageController(initialPage: _indexOf(widget.date ?? todayIso()));
  List<String> _favorites = [];

  int _indexOf(String date) => _today.difference(DateTime.parse(date)).inDays.clamp(0, _dayCount - 1);
  String _dateAt(int index) => isoDate(DateTime(_today.year, _today.month, _today.day - index));

  @override
  void initState() {
    super.initState();
    AuthService().getFavorites().then((favorites) {
      if (mounted) setState(() => _favorites = List<String>.from(favorites));
    });
  }

  @override
  void dispose() {
    final before = _ambientBefore;
    // Home gets its color back once this page is gone.
    WidgetsBinding.instance.addPostFrameCallback((_) => ambientPicture.value = before);
    _pages.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(String date) async {
    final i10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final wasFavorite = _favorites.contains(date);
    HapticFeedback.lightImpact();
    setState(() => wasFavorite ? _favorites.remove(date) : _favorites.add(date));
    if (wasFavorite) {
      await AuthService().removeFavorite(date);
    } else {
      await AuthService().addFavorite(date);
    }
    if (mounted) messenger.showSnackBar(SnackBar(content: Text(wasFavorite ? i10n.favoriteRemoved : i10n.favoriteAdded)));
  }

  void _back() {
    final navigator = Navigator.of(context);
    navigator.canPop() ? navigator.pop() : navigator.pushReplacementNamed(AppRoutes.home);
  }

  void _openDay(String? date) {
    if (date == null) return;
    final target = _indexOf(date);
    if (reduceMotion(context)) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(target, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    }
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    // The web address follows the day, so a reload or a shared link lands here.
    if (kIsWeb) SystemNavigator.routeInformationUpdated(uri: Uri.parse(AppRoutes.day(_dateAt(index))), replace: true);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final date = _dateAt(_pages.page?.round() ?? 0);
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _openDay(shiftDay(date, -1));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _openDay(shiftDay(date, 1));
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _back();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final isDesktop = context.isDesktop;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: AppBackground()),
              Positioned.fill(
                child: PageView.builder(
                  controller: _pages,
                  // Keeps the next day ready, so it is there when the finger arrives.
                  allowImplicitScrolling: true,
                  itemCount: _dayCount,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final date = _dateAt(index);
                    return _DayPage(
                      key: ValueKey(date),
                      date: date,
                      service: _service,
                      isFavorite: _favorites.contains(date),
                      onToggleFavorite: () => _toggleFavorite(date),
                      onOpenDay: _openDay,
                      isCurrent: () => _pages.hasClients && _pages.page?.round() == index,
                    );
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
      ),
    );
  }
}

class _DayPage extends StatefulWidget {
  final String date;
  final NetworkService service;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final ValueChanged<String?> onOpenDay;
  final bool Function() isCurrent;
  const _DayPage({super.key, required this.date, required this.service, required this.isFavorite, required this.onToggleFavorite, required this.onOpenDay, required this.isCurrent});

  @override
  State<_DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<_DayPage> {
  late Future<Map<String, dynamic>> _day = widget.service.getApod(widget.date);
  String? _translated;
  bool _translating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _day.then((day) {
      if (mounted && widget.isCurrent()) setAmbientFrom(day);
    }, onError: (Object _) {});
  }

  @override
  void didUpdateWidget(_DayPage old) {
    super.didUpdateWidget(old);
    _day.then((day) {
      if (mounted && widget.isCurrent()) setAmbientFrom(day);
    }, onError: (Object _) {});
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

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    return FutureBuilder<Map<String, dynamic>>(
      future: _day,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          return StateMessage(
            icon: Icons.cloud_off_rounded,
            title: i10n.genericError,
            body: apodErrorText(i10n, error is NasaApiException ? error.statusCode : null),
            actionLabel: i10n.retry,
            onAction: () => setState(() => _day = widget.service.getApod(widget.date)),
          );
        }
        final apod = snapshot.data;
        if (apod == null) return _Loading(wide: isDesktop);
        return isDesktop ? _wide(apod, i10n) : _phone(apod, i10n);
      },
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
          child: _Stage(apod: apod, date: widget.date, fit: BoxFit.cover, radius: 0),
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
          Expanded(child: _Stage(apod: apod, date: widget.date, fit: BoxFit.contain, radius: AppTheme.radiusHero, backdrop: Colors.transparent)),
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
    final isFavorite = widget.isFavorite;
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
                onPressed: widget.onToggleFavorite,
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

  void _share(Map<String, dynamic> apod) => shareApod(context, title: (apod['title'] ?? '') as String, date: widget.date, imageUrl: (apod['url'] ?? '') as String, credit: apod['copyright'] as String?);
  void _download(Map<String, dynamic> apod) => saveNetworkImage(context, (apod['url'] ?? '') as String, (apod['title'] ?? '') as String);

  List<Widget> _story(Map<String, dynamic> apod, AppLocalizations i10n, {required double titleSize}) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final credit = (apod['copyright'] as String?)?.replaceAll('\n', ' ').trim() ?? '';
    final explanation = (apod['explanation'] ?? '') as String;
    final previous = shiftDay(widget.date, -1);
    final next = shiftDay(widget.date, 1);
    final text = _translated ?? explanation;
    return [
      Text(longDate(widget.date, locale), style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontSize: 13)),
      const SizedBox(height: 8),
      Text((apod['title'] ?? '') as String, style: theme.textTheme.displaySmall?.copyWith(fontSize: titleSize)),
      const SizedBox(height: 10),
      if (credit.isNotEmpty) ...[
        Text('${i10n.imageCredit}: $credit', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
      ],
      // On touch screens a drag here must move the panel, not select text.
      if (context.isDesktop) SelectableText(text, style: theme.textTheme.bodyLarge) else Text(text, style: theme.textTheme.bodyLarge),
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
            Expanded(child: OutlinedButton.icon(onPressed: () => widget.onOpenDay(previous), icon: const Icon(Icons.chevron_left_rounded), label: Text(i10n.previousDay, maxLines: 1, overflow: TextOverflow.ellipsis))),
          if (previous != null && next != null) const SizedBox(width: 8),
          if (next != null)
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: OutlinedButton.icon(onPressed: () => widget.onOpenDay(next), icon: const Icon(Icons.chevron_left_rounded), label: Text(i10n.nextDay, maxLines: 1, overflow: TextOverflow.ellipsis)),
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
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder<void>(
                opaque: false,
                barrierColor: Colors.black,
                pageBuilder: (context, _, __) => _FullScreenPhoto(apod: apod),
                transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
              ),
            ),
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

/// The whole picture: pinch or double tap to zoom, drag down to close. The
/// screen-sized version shows at once, and the full one replaces it when ready.
class _FullScreenPhoto extends StatefulWidget {
  final Map<String, dynamic> apod;
  const _FullScreenPhoto({required this.apod});

  @override
  State<_FullScreenPhoto> createState() => _FullScreenPhotoState();
}

class _FullScreenPhotoState extends State<_FullScreenPhoto> with SingleTickerProviderStateMixin {
  static const _doubleTapZoom = 2.5;
  final _transform = TransformationController();
  late final _zoom = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  Animation<Matrix4>? _zoomAnimation;
  Offset _lastTap = Offset.zero;
  double _dragDown = 0;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      if (_zoomAnimation != null) _transform.value = _zoomAnimation!.value;
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final target = _zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
          ..translateByDouble(_lastTap.dx * (1 - _doubleTapZoom), _lastTap.dy * (1 - _doubleTapZoom), 0, 1)
          ..scaleByDouble(_doubleTapZoom, _doubleTapZoom, _doubleTapZoom, 1));
    _zoomAnimation = Matrix4Tween(begin: _transform.value, end: target).animate(CurvedAnimation(parent: _zoom, curve: Curves.easeOutCubic));
    _zoom.forward(from: 0);
    setState(() => _zoomed = !_zoomed);
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final apod = widget.apod;
    final screenUrl = apodImageUrl(apod['url'] as String);
    final fullUrl = proxiedImageUrl((apod['hdurl'] ?? apod['url']) as String);
    final credit = apod['copyright'] as String?;
    final photo = Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: screenUrl,
          fit: BoxFit.contain,
          fadeInDuration: Duration.zero,
          progressIndicatorBuilder: (context, _, __) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          errorWidget: (context, _, __) => Center(child: Text(i10n.imageLoadError, style: const TextStyle(color: Colors.white))),
        ),
        // If the full version fails, the screen-sized one simply stays.
        Image.network(
          fullUrl,
          fit: BoxFit.contain,
          frameBuilder: (context, child, frame, _) => frame == null ? const SizedBox.shrink() : child,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: (details) => _lastTap = details.localPosition,
              onDoubleTap: _toggleZoom,
              // Dragging down closes the view, unless the picture is zoomed in.
              onVerticalDragUpdate: _zoomed ? null : (details) => setState(() => _dragDown = (_dragDown + details.delta.dy).clamp(0, 600)),
              onVerticalDragEnd: _zoomed
                  ? null
                  : (details) {
                      if (_dragDown > 120 || (details.primaryVelocity ?? 0) > 700) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() => _dragDown = 0);
                      }
                    },
              child: AnimatedContainer(
                duration: _dragDown == 0 ? const Duration(milliseconds: 200) : Duration.zero,
                transform: Matrix4.translationValues(0, _dragDown, 0),
                child: InteractiveViewer(
                  transformationController: _transform,
                  maxScale: 8,
                  panEnabled: _zoomed,
                  onInteractionEnd: (_) {
                    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
                    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
                  },
                  child: SizedBox.expand(child: photo),
                ),
              ),
            ),
          ),
          if (credit != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('${i10n.imageCredit}: $credit', style: const TextStyle(color: Colors.white, fontSize: 12, shadows: [Shadow(blurRadius: 6)])),
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
    );
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
