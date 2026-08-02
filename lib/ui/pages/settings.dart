import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/provider/locale_provider.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:provider/provider.dart';
import 'package:nasa_apod/utils/language.dart';
import 'package:nasa_apod/ui/responsive/responsive.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    if (!mounted) return;
    navigator.pushNamed('/login');
  }

  Future<void> _checkAuthentication() async {
    isLoggedIn = await AuthService().isLoggedIn();
    setState(() {});
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
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const TitleArea(text: 'Ajustes', subtitle: 'Personaliza tu experiencia'),
            const SizedBox(height: 28),

            // ── Apariencia ────────────────────────────────────────────────
            _SettingsSectionHeader(text: i10n.appeareance.toUpperCase()),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  iconColor: isDark ? const Color(0xFF5E9EFF) : const Color(0xFF1A73E8),
                  iconBackground: isDark
                      ? const Color(0xFF5E9EFF).withValues(alpha: 0.15)
                      : const Color(0xFF1A73E8).withValues(alpha: 0.12),
                  title: i10n.darkMode,
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeTrackColor: const Color(0xFF5E9EFF).withValues(alpha: 0.5),
                    activeColor: const Color(0xFF5E9EFF),
                    thumbColor: WidgetStatePropertyAll(
                      isDark ? scheme.surface : Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Idioma ────────────────────────────────────────────────────
            _SettingsSectionHeader(text: i10n.language.toUpperCase()),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _LanguageSegmented(
                    currentLanguage: currentLanguage,
                    onChanged: (locale) {
                      localeProvider.setLocale(locale);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Cuenta ────────────────────────────────────────────────────
            _SettingsSectionHeader(text: i10n.account.toUpperCase()),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: isLoggedIn
                      ? Icons.logout_rounded
                      : Icons.login_rounded,
                  iconColor: isLoggedIn
                      ? const Color(0xFFE85D5D)
                      : const Color(0xFF2DD4BF),
                  iconBackground: isLoggedIn
                      ? const Color(0xFFE85D5D).withValues(alpha: 0.14)
                      : const Color(0xFF2DD4BF).withValues(alpha: 0.14),
                  title: isLoggedIn ? i10n.logout : i10n.login,
                  subtitle: isLoggedIn
                      ? 'Cerrar sesión en este dispositivo'
                      : 'Accede para sincronizar favoritos',
                  showChevron: true,
                  onTap: isLoggedIn
                      ? handleLogout
                      : () => Navigator.pushNamed(context, '/login'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Extras ────────────────────────────────────────────────────
            _SettingsSectionHeader(text: i10n.extras.toUpperCase()),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBackground: const Color(0xFF8B5CF6).withValues(alpha: 0.14),
                  title: i10n.diariesNotification,
                  trailing: const _ComingSoonChip(),
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.download_for_offline_rounded,
                  iconColor: const Color(0xFF2DD4BF),
                  iconBackground: const Color(0xFF2DD4BF).withValues(alpha: 0.14),
                  title: i10n.qualityDownload,
                  trailing: const _ComingSoonChip(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Acerca de ─────────────────────────────────────────────────
            _SettingsSectionHeader(text: 'ACERCA DE'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.rocket_launch_rounded,
                  iconColor: const Color(0xFF5E9EFF),
                  iconBackground: const Color(0xFF5E9EFF).withValues(alpha: 0.14),
                  title: 'Appod',
                  subtitle: 'Astronomy Picture of the Day',
                  trailing: Text(
                    'v1.2',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.code_rounded,
                  iconColor: const Color(0xFF0A0E14),
                  iconBackground: const Color(0xFF0A0E14).withValues(alpha: 0.08),
                  iconWidget: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0A0E14),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/github-mark.svg',
                      width: 18,
                      height: 18,
                    ),
                  ),
                  title: 'Repositorio en GitHub',
                  subtitle: 'github.com/Doble-2/Appod-AstronomyPictureOfDay',
                  showChevron: true,
                  onTap: () async {
                    final uri = Uri.parse(
                        'https://github.com/Doble-2/Appod-AstronomyPictureOfDay');
                    await ul.launchUrl(
                        uri, mode: ul.LaunchMode.externalApplication);
                  },
                  onLongPress: () async {
                    const url =
                        'https://github.com/Doble-2/Appod-AstronomyPictureOfDay';
                    await Clipboard.setData(const ClipboardData(text: url));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Enlace copiado al portapapeles')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Componentes ──────────────────────────────────────────────────────────

/// Segmented control estilo iOS para elegir idioma: indicador deslizante
/// animado entre opciones, con bandera y nombre.
class _LanguageSegmented extends StatelessWidget {
  final Locale currentLanguage;
  final ValueChanged<Locale> onChanged;

  const _LanguageSegmented({
    required this.currentLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langs = Language.values;
    final selectedIndex = langs.indexWhere(
        (l) => l.localeValue.languageCode == currentLanguage.languageCode);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / langs.length;
        return Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Indicador deslizante (iOS segmented) — posicionado exacto
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: 4 + selectedIndex * itemWidth,
                top: 4,
                width: itemWidth - 8,
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Opciones
              Row(
                children: langs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lang = entry.value;
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!isSelected) onChanged(lang.localeValue);
                        },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1 : 0.55,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Bandera con altura fija para alinear con el texto
                              SizedBox(
                                width: 24,
                                height: 20,
                                child: Center(
                                  child: Text(lang.flag,
                                      style: const TextStyle(
                                          fontSize: 16, height: 1)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lang.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? scheme.onSurface
                                      : scheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Título de sección estilo iOS: mayúscula pequeña, gris, con aire.
class _SettingsSectionHeader extends StatelessWidget {
  final String text;
  const _SettingsSectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: scheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

/// Card de grupo agrupada (inset grouped), glass con borde hairline.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surface.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const _SettingsDivider(),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Fila de ajuste con icono en contenedor tintado, título, subtítulo
/// opcional y trailing — el patrón de la app Ajustes de iOS.
class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconColor;
  final Color? iconBackground;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _SettingsTile({
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.iconBackground,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveIcon = iconWidget ??
        (icon != null
            ? Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackground ??
                      scheme.primary.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19, color: iconColor ?? scheme.primary),
              )
            : null);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            if (effectiveIcon != null) ...[
              effectiveIcon,
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
            if (showChevron)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: scheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 62,
      endIndent: 14,
      color: scheme.onSurface.withValues(alpha: 0.08),
    );
  }
}

class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip();

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        i10n.soon,
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
