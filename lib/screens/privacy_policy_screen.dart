import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_info.dart';
import '../data/privacy_policy_content.dart';
import '../l10n/app_strings.dart';

/// Full in-app Privacy Policy with EN / VI / Simplified-Chinese tabs.
/// The Chinese tab is required while "Chinese mainland" is selected as a
/// release region on AppGallery Connect (review issue #2).
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, required this.initialLanguageCode});

  final String initialLanguageCode;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late String _code = widget.initialLanguageCode;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_code);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('privacyPolicy'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Identity card — exact strings required by Huawei (issue #3).
          Card(
            color: const Color(0xFFEAF3FF),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Developer Name: ${AppInfo.developerName}',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  const Text('App Name: ${AppInfo.appName}'),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => launchUrl(
                        Uri.parse('mailto:${AppInfo.contactEmail}')),
                    child: const Text(
                      'Contact Email: ${AppInfo.contactEmail}',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              for (final code in AppStrings.supportedCodes)
                ButtonSegment(
                    value: code, label: Text(AppStrings.languageName(code))),
            ],
            selected: {_code},
            onSelectionChanged: (s) => setState(() => _code = s.first),
          ),
          const SizedBox(height: 16),
          SelectableText(PrivacyPolicyContent.textFor(_code)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: Text(strings.t('privacyPolicy')),
            onPressed: () =>
                launchUrl(Uri.parse(AppInfo.privacyPolicyUrl)),
          ),
        ],
      ),
    );
  }
}

/// Very short Terms shown from the first-launch consent pop-up.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(languageCode);
    const body = '''
${AppInfo.appName}
Developer Name: ${AppInfo.developerName}
Contact Email: ${AppInfo.contactEmail}

By tapping "Agree" you accept that:
• The App locks your screen and shows the system volume panel only when you ask it to (button, notification action or floating control).
• The Accessibility Service, Device Administrator, battery-optimization exemption and Foreground Service are optional, off by default where the system allows, and are used only for the purposes explained in the Privacy Policy.
• The App is provided "as is", free of charge, supported by banner advertising.
''';
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('termsOfService'))),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SelectableText(body),
      ),
    );
  }
}
