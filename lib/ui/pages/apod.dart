import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:nasa_apod/ui/widgets/molecules/download_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/share_apod.dart';
import 'package:nasa_apod/ui/widgets/molecules/translate_description.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
import 'package:nasa_apod/utils/image_proxy.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// One day of the archive: the picture first, then its story.
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
    if (wasFavorite) {
      await AuthService().removeFavorite(_date);
    } else {
      await AuthService().addFavorite(_date);
    }
    if (!mounted) return;
    setState(() => wasFavorite ? _favorites.remove(_date) : _favorites.add(_date));
    messenger.showSnackBar(SnackBar(content: Text(wasFavorite ? i10n.favoriteRemoved : i10n.favoriteAdded)));
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

  void _openDay(String date) => Navigator.of(context).pushReplacementNamed('/apod/$date');

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            // A shared link opens this page first, with nothing to go back to.
            final navigator = Navigator.of(context);
            navigator.canPop() ? navigator.pop() : navigator.pushReplacementNamed('/home');
          },
        ),
        title: const Text('APPOD', style: TextStyle(fontFamily: 'Nasa', fontSize: 20)),
      ),
      body: BlocBuilder<ApodBloc, ApodState>(
        builder: (context, state) {
          if (state.status == ApodStatus.failed) {
            return StateMessage(
              icon: Icons.cloud_off_rounded,
              title: i10n.genericError,
              body: apodErrorText(i10n, state.errorCode),
              actionLabel: i10n.retry,
              onAction: () => context.read<ApodBloc>().add(ChangeDate(_date)),
            );
          }
          final apod = state.apodData;
          if (state.status != ApodStatus.success || apod == null || apod['date'] != _date) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 56),
            child: Column(
              children: [
                _Stage(apod: apod),
                const SizedBox(height: 28),
                PageBody(maxWidth: 760, child: _article(apod, i10n)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _article(Map<String, dynamic> apod, AppLocalizations i10n) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isImage = apod['media_type'] == 'image';
    final isFavorite = _favorites.contains(_date);
    final title = (apod['title'] ?? '') as String;
    final url = (apod['url'] ?? '') as String;
    final credit = (apod['copyright'] as String?)?.replaceAll('\n', ' ').trim();
    final explanation = (apod['explanation'] ?? '') as String;
    final previous = shiftDay(_date, -1);
    final next = shiftDay(_date, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(longDate(_date, locale), style: theme.textTheme.labelSmall?.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        Text(title, style: theme.textTheme.displaySmall?.copyWith(fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 44)),
        if (credit != null && credit.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('${i10n.imageCredit}: $credit', style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18, color: isFavorite ? theme.colorScheme.primary : null),
              label: Text(isFavorite ? i10n.removeFromFavorites : i10n.addToFavorites),
            ),
            OutlinedButton.icon(
              onPressed: () => shareApod(context, title: title, date: _date, imageUrl: url),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(i10n.share),
            ),
            if (isImage)
              OutlinedButton.icon(
                onPressed: () => saveNetworkImage(context, url, title),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(i10n.downloadApod),
              ),
          ],
        ),
        const SizedBox(height: 28),
        SelectableText(_translated ?? explanation, style: theme.textTheme.bodyLarge),
        // NASA writes in English, so translation is only offered to other readers.
        if (locale != 'en' && _translated == null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _translating ? null : () => _translate(explanation, i10n),
            icon: _translating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.translate_rounded, size: 18),
            label: Text(_translating ? i10n.translating : i10n.translate),
          ),
        ],
        const SizedBox(height: 36),
        const Divider(),
        const SizedBox(height: 12),
        Row(
          children: [
            if (previous != null)
              TextButton.icon(
                onPressed: () => _openDay(previous),
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(i10n.previousDay),
              ),
            const Spacer(),
            if (next != null)
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextButton.icon(
                  onPressed: () => _openDay(next),
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: Text(i10n.nextDay),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The picture on black, never cropped. Tapping it opens the full view.
class _Stage extends StatelessWidget {
  final Map<String, dynamic> apod;
  const _Stage({required this.apod});

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
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    tooltip: i10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
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
    final maxHeight = MediaQuery.of(context).size.height * 0.72;
    if (apod['media_type'] != 'image') {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxHeight * 16 / 9),
            child: AspectRatio(aspectRatio: 16 / 9, child: _ApodVideo(url: apod['url'] as String)),
          ),
        ),
      );
    }
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Semantics(
        button: true,
        label: i10n.viewFullScreen,
        child: Tooltip(
          message: i10n.viewFullScreen,
          child: InkWell(
            onTap: () => _openFullScreen(context),
            mouseCursor: SystemMouseCursors.zoomIn,
            // The stage takes the picture's own shape, up to the height limit.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 240, maxHeight: maxHeight),
              child: Center(
                heightFactor: 1,
                child: Image.network(
                  proxiedImageUrl(apod['url'] as String),
                  fit: BoxFit.contain,
                  frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
                    opacity: sync || frame != null ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  ),
                  errorBuilder: (context, error, stack) =>
                      Text(i10n.imageLoadError, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
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
