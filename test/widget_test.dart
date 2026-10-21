import 'package:flutter_test/flutter_test.dart';
import 'package:power_volume/main.dart';
import 'package:power_volume/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PowerVolumeApp> buildApp({required bool privacyAccepted}) async {
    SharedPreferences.setMockInitialValues({
      'is_privacy_accepted': privacyAccepted,
    });
    final prefs = await PreferencesService.load();
    return PowerVolumeApp(
      preferences: prefs,
      initialPrivacyAccepted: privacyAccepted,
      initialLanguageCode: 'en',
    );
  }

  testWidgets(
    'first launch shows the Privacy Policy pop-up and blocks the home UI '
    '(AppGallery issue #1)',
    (tester) async {
      await tester.pumpWidget(await buildApp(privacyAccepted: false));
      await tester.pump();

      expect(find.text('Welcome to Power & Volume'), findsOneWidget);
      expect(find.text('Agree'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsWidgets);
      // Home features must NOT be reachable before consent.
      expect(find.text('LOCK SCREEN'), findsNothing);
    },
  );

  testWidgets('tapping Agree persists consent and reveals the home UI',
      (tester) async {
    await tester.pumpWidget(await buildApp(privacyAccepted: false));
    await tester.pump();

    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();

    expect(find.text('LOCK SCREEN'), findsOneWidget);
    final prefs = await PreferencesService.load();
    expect(prefs.isPrivacyAccepted, isTrue);
  });

  testWidgets(
    'Keep-Alive Foreground Service switch is OFF by default '
    '(AppGallery issue #4)',
    (tester) async {
      SharedPreferences.setMockInitialValues({'is_privacy_accepted': true});
      final prefs = await PreferencesService.load();

      expect(prefs.keepAliveEnabled, isFalse);
      expect(prefs.hasForegroundServiceConsent, isFalse);
    },
  );
}
