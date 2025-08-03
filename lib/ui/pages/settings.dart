import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/ui/widgets/atoms/title_area.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return  SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const TitleArea(text: 'Apariencia'),
            const SizedBox(height: 16),
            _SettingsCard(
              child: ListTile(
                leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: Theme.of(context).colorScheme.primary),
                title: const Text('Modo Oscuro'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  
                  inactiveThumbColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const TitleArea(text: 'Cuenta'),
            const SizedBox(height: 16),
            _SettingsCard(
              child: ListTile(
                leading: Icon(isLoggedIn ? Icons.logout_rounded : Icons.login_rounded, color: Theme.of(context).colorScheme.primary),
                title: Text(isLoggedIn ? 'Cerrar Sesión' : 'Iniciar Sesión'),
                onTap: isLoggedIn
                    ? handleLogout
                    : () => Navigator.pushNamed(context, '/login'),
              ),
            ),
            const SizedBox(height: 32),
            const TitleArea(text: 'Extras'),
            const SizedBox(height: 16),
            _SettingsCard(
              child: ListTile(
                leading: Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.onSurface),
                title: Text('Notificaciones diarias', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                trailing: const _ComingSoonChip(),
              ),
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              child: ListTile(
                    leading: Icon(Icons.download_for_offline_rounded, color: Theme.of(context).colorScheme.onSurface),
                    title: Text('Calidad de descarga', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                trailing: const _ComingSoonChip(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ))
        ;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Pronto',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
