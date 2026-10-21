import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_info.dart';
import '../l10n/app_strings.dart';

/// "Support Developer (Optional)" card — restored as its own module.
///
/// Contains the exact free-utility text plus working Payoneer / VietQR
/// donate actions. It lives inside the scrollable content, directly above
/// the fixed bottom ad banner (which is pinned outside the scroll view).
class SupportDeveloperCard extends StatelessWidget {
  const SupportDeveloperCard({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFFE082)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.coffee, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.t('supportTitle'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Exact copy required by the product spec (EN source string):
            // "This utility is 100% free. If you find it helpful, feel free
            //  to buy the developer a coffee via Payoneer or VietQR!"
            Text(strings.t('supportBody')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.volunteer_activism, size: 18),
                  label: Text(strings.t('donateViaPayoneer')),
                  onPressed: () => _showPayoneerDialog(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: Text(strings.t('donateViaVietQr')),
                  onPressed: () => _showVietQrDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPayoneerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.volunteer_activism),
        title: Text(strings.t('donateViaPayoneer')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.t('payoneerDialogBody')),
            const SizedBox(height: 12),
            const SelectableText(
              AppInfo.payoneerEmail,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: Text(strings.t('copyEmail')),
            onPressed: () async {
              await Clipboard.setData(
                  const ClipboardData(text: AppInfo.payoneerEmail));
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.t('emailCopied'))));
            },
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.t('close')),
          ),
        ],
      ),
    );
  }

  void _showVietQrDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.qr_code_2),
        title: Text(strings.t('donateViaVietQr')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.t('vietQrDialogBody')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1E88E5)),
                borderRadius: BorderRadius.circular(12),
              ),
              // VietQR image/payload is provided by the developer
              // (AppInfo.vietQrInfo) — bank name + account holder.
              child: const Column(
                children: [
                  Icon(Icons.qr_code_2, size: 72, color: Color(0xFF1E88E5)),
                  SizedBox(height: 8),
                  SelectableText(
                    AppInfo.vietQrInfo,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.t('close')),
          ),
        ],
      ),
    );
  }
}
