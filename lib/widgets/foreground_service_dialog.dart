import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// Review issue #4 — the Keep-Alive Foreground Service must never start
/// silently. Every time the user switches it ON we explain, in their own
/// language, what will happen, and only an explicit "Enable" tap may call
/// `NativeBridge.startForegroundService()`.
///
/// Returns `true` only when the user tapped Enable.
Future<bool> showForegroundServiceConsentDialog(
  BuildContext context,
  AppStrings strings,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.notifications_active_outlined, size: 36),
      title: Text(strings.t('fgDialogTitle')),
      content: Text(strings.t('fgDialogBody')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(strings.t('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(strings.t('enable')),
        ),
      ],
    ),
  );
  return result ?? false;
}
