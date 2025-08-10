import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/provider/locale_provider.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasa_apod/utils/language.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';

class SettingsView extends StatefulWidget {
  final AuthService authService;

  const SettingsView({super.key, required this.authService});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isLoggedIn = false;
  void handleLogout() async {
    final navigator = Navigator.of(context);
    await widget.authService.logout();
    // Clear user data from SharedPreferences (opcional)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userUID');
    if (!mounted) return;
    navigator.pushNamed('/login');
  }

  Future<void> _checkAuthentication() async {
    // Replace with your actual authentication logic
    isLoggedIn = await AuthService().isLoggedIn();

    setState(() {
      isLoggedIn = isLoggedIn;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i10n = AppLocalizations.of(context)!;
    final currentLanguage = localeProvider.selectedLanguage;

    return SingleChildScrollView(
        child: MaxWidthContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          TitleArea(text: i10n.appeareance),
          const SizedBox(height: 16),
          _SettingsCard(
            child: ListTile(
              leading: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(i10n.darkMode),
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                inactiveThumbColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha(77),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          TitleArea(text: i10n.language),
            const SizedBox(height: 16),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: Language.values.map((lang) {
                  final isSelected = lang.localeValue == currentLanguage;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          localeProvider.setLocale(lang.localeValue);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang.flag,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(lang.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          TitleArea(text: i10n.account),
          const SizedBox(height: 16),
          _SettingsCard(
            child: ListTile(
              leading: Icon(
                  isLoggedIn
                      ? Icons.logout_rounded
                      : Icons.login_rounded,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(isLoggedIn ? i10n.logout : i10n.login),
              onTap: isLoggedIn
                  ? handleLogout
                  : () => Navigator.pushNamed(context, '/login'),
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 32),
          TitleArea(text: i10n.extras),
          const SizedBox(height: 16),
          _SettingsCard(
            child: ListTile(
              leading: Icon(Icons.notifications_active_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(i10n.diariesNotification,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              trailing: const _ComingSoonChip(),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            child: ListTile(
              leading: Icon(Icons.download_for_offline_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(i10n.qualityDownload,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              trailing: const _ComingSoonChip(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ));
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip();

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        i10n.soon,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
