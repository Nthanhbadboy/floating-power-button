import 'package:flutter/material.dart';

import 'constants/app_info.dart';
import 'screens/home_screen.dart';
import 'services/preferences_service.dart';
import 'widgets/privacy_consent_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted state BEFORE the first frame so that:
  //  * the Privacy Policy pop-up (review issue #1) is the very first thing a
  //    new user sees — no flash of the home screen, and
  //  * the Keep-Alive switch can default to OFF (review issue #4).
  final preferences = await PreferencesService.load();

  runApp(PowerVolumeApp(
    preferences: preferences,
    initialPrivacyAccepted: preferences.isPrivacyAccepted,
    initialLanguageCode: preferences.languageCode,
  ));
}

class PowerVolumeApp extends StatelessWidget {
  const PowerVolumeApp({
    super.key,
    required this.preferences,
    required this.initialPrivacyAccepted,
    required this.initialLanguageCode,
  });

  final PreferencesService preferences;
  final bool initialPrivacyAccepted;
  final String initialLanguageCode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      home: PrivacyConsentGate(
        preferences: preferences,
        initialPrivacyAccepted: initialPrivacyAccepted,
        initialLanguageCode: initialLanguageCode,
        child: HomeScreen(preferences: preferences),
      ),
    );
  }
}
