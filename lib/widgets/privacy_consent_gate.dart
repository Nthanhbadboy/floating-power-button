import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../screens/privacy_policy_screen.dart';
import '../services/preferences_service.dart';

/// Review issue #1 — on the very first launch the app MUST show a Privacy
/// Policy pop-up and must not be usable until the user taps "Agree".
///
/// * Non-dismissible: no barrier tap, no back button (PopScope canPop:false).
/// * "Agree" persists `is_privacy_accepted = true` via shared_preferences.
/// * "Decline" exits the app — there is no way around the gate.
/// * The pop-up is shown in the user's selected language (EN / VI / 中文).
class PrivacyConsentGate extends StatefulWidget {
  const PrivacyConsentGate({
    super.key,
    required this.preferences,
    required this.initialPrivacyAccepted,
    required this.initialLanguageCode,
    required this.child,
  });

  final PreferencesService preferences;
  final bool initialPrivacyAccepted;
  final String initialLanguageCode;
  final Widget child;

  @override
  State<PrivacyConsentGate> createState() => _PrivacyConsentGateState();
}

class _PrivacyConsentGateState extends State<PrivacyConsentGate> {
  late bool _accepted = widget.initialPrivacyAccepted;
  late String _code = widget.initialLanguageCode;

  Future<void> _agree() async {
    await widget.preferences.setPrivacyAccepted(true);
    if (mounted) setState(() => _accepted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted) return widget.child;

    final strings = AppStrings(_code);
    // The home screen is NOT built at all behind the gate, so no service,
    // permission or ad can start before consent.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FB),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.privacy_tip_outlined,
                          size: 48, color: Color(0xFF1E88E5)),
                      const SizedBox(height: 16),
                      Text(
                        strings.t('welcome'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(strings.t('privacyConsentBody'),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PrivacyPolicyScreen(
                                    initialLanguageCode: _code),
                              ),
                            ),
                            child: Text(strings.t('privacyPolicy')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TermsOfServiceScreen(
                                    languageCode: _code),
                              ),
                            ),
                            child: Text(strings.t('termsOfService')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _agree,
                        child: Text(strings.t('agree')),
                      ),
                      TextButton(
                        // No consent -> no app. This is intentional.
                        onPressed: () => SystemNavigator.pop(),
                        child: Text(strings.t('decline')),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          for (final code in AppStrings.supportedCodes)
                            ButtonSegment(
                              value: code,
                              label: Text(AppStrings.languageName(code)),
                            ),
                        ],
                        selected: {_code},
                        onSelectionChanged: (s) async {
                          setState(() => _code = s.first);
                          await widget.preferences
                              .setLanguageCode(s.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
