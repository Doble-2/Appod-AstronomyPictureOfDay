import 'package:flutter/material.dart';

/// Botón premium con estado de carga estilo Apple:
/// muestra un spinner con glow mientras [loading] es true y bloquea el tap.
class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool loading;
  final IconData? icon;
  final String? loadingLabel;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.loading = false,
    this.icon,
    this.loadingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: scheme.onPrimary,
              ),
            )
          : (icon != null ? Icon(icon) : const SizedBox.shrink()),
      label: loading
          ? Text(loadingLabel ?? '…')
          : child,
      style: FilledButton.styleFrom(
        disabledBackgroundColor: scheme.primary.withValues(alpha: 0.7),
        disabledForegroundColor: scheme.onPrimary,
      ),
    );
  }
}
