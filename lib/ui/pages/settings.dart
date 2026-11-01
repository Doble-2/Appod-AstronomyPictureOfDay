import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/provider/locale_provider.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class SettingsView extends StatefulWidget {
  final AuthService authService;
  const SettingsView({super.key, required this.authService});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  static const _repository = 'https://github.com/Doble-2/Appod-AstronomyPictureOfDay';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    widget.authService.isLoggedIn().then((value) {
      if (mounted) setState(() => _isLoggedIn = value);
    });
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await widget.authService.logout();
    if (mounted) navigator.pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    return PageBody(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(i10n.settings, style: theme.textTheme.displaySmall),
          SectionGroup(
            title: i10n.appeareance,
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(i10n.systemMode)),
                  ButtonSegment(value: ThemeMode.light, label: Text(i10n.lightMode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(i10n.darkMode)),
                ],
                selected: {themeProvider.themeMode},
                onSelectionChanged: (s) => themeProvider.setThemeMode(s.first),
              ),
            ),
          ),
          SectionGroup(
            title: i10n.language,
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'es', label: Text('Español')),
                ],
                selected: {localeProvider.selectedLanguage.languageCode},
                onSelectionChanged: (s) => localeProvider.setLocale(Locale(s.first)),
              ),
            ),
          ),
          SectionGroup(
            title: i10n.account,
            child: _isLoggedIn
                ? OutlinedButton(onPressed: _logout, child: Text(i10n.logout))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i10n.loginToSync, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.login), child: Text(i10n.login)),
                    ],
                  ),
          ),
          SectionGroup(
            title: i10n.about,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i10n.aboutBody, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                if (kIsWeb) ...[
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.getApp),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(i10n.getApp),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () => ul.launchUrl(Uri.parse(_repository), mode: ul.LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(i10n.sourceCode),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
