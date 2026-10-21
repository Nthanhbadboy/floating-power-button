import 'package:flutter_test/flutter_test.dart';
import 'package:power_volume/data/manufacturer_guides.dart';
import 'package:power_volume/data/privacy_policy_content.dart';
import 'package:power_volume/l10n/app_strings.dart';
import 'package:power_volume/main.dart';
import 'package:power_volume/widgets/ads/ad_banner_host.dart';
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
    'ad banner is pinned in bottomNavigationBar and the Support Developer '
    'card with Payoneer/VietQR sits above it in the scroll area',
    (tester) async {
      await tester.pumpWidget(await buildApp(privacyAccepted: true));
      await tester.pumpAndSettle();

      // Banner lives OUTSIDE the scroll view (Scaffold.bottomNavigationBar).
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.bottomNavigationBar, isA<AdBannerHost>());
      expect(find.byType(AdBannerHost), findsOneWidget);

      // Support Developer card is reachable by scrolling, banner stays put.
      await tester.scrollUntilVisible(
          find.text('Donate via Payoneer'), 200);
      expect(find.text('Support Developer (Optional)'), findsOneWidget);
      expect(find.textContaining('buy the developer a coffee via Payoneer '
          'or VietQR!'), findsOneWidget);
      expect(find.text('Donate via VietQR'), findsOneWidget);
      expect(find.byType(AdBannerHost), findsOneWidget);
    },
  );

  test('Spanish (ES) localization resolves dialogs, guides and policy', () {
    final es = AppStrings('es');
    expect(es.t('agree'), 'Aceptar');
    expect(es.t('fgDialogTitle'), contains('Keep-Alive'));
    expect(es.t('donateViaPayoneer'), 'Donar vía Payoneer');
    for (final guide in ManufacturerGuides.all) {
      expect(guide.stepsFor('es'), isNotEmpty, reason: guide.id);
      expect(guide.settingsButtonFor('es'), isNotEmpty, reason: guide.id);
    }
    expect(PrivacyPolicyContent.textFor('es'),
        contains('NGUYEN MINH THANH'));
    expect(PrivacyPolicyContent.textFor('zh'),
        contains('NGUYEN MINH THANH'));
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
