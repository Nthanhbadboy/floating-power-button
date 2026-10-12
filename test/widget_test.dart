import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_power_button/src/app.dart';
import 'package:floating_power_button/src/overlay/overlay_service.dart';

import 'helpers/fake_overlay_service.dart';

OverlayStatus _state({
  bool permission = true,
  bool enabled = false,
  bool running = false,
}) {
  return OverlayStatus(
    overlayPermissionGranted: permission,
    enabled: enabled,
    serviceRunning: running,
  );
}

Future<void> _pumpApp(WidgetTester tester, FakeOverlayService service) async {
  await tester.pumpWidget(FloatingPowerButtonApp(overlayService: service));
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Open settings'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home screen reports a running floating button', (tester) async {
    await _pumpApp(
      tester,
      FakeOverlayService(state: _state(enabled: true, running: true)),
    );

    expect(find.text('Floating Power Button'), findsOneWidget);
    expect(find.textContaining('is running'), findsOneWidget);
  });

  testWidgets('home screen explains a missing overlay permission', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      FakeOverlayService(state: _state(permission: false)),
    );

    expect(
      find.textContaining('Overlay permission is not granted'),
      findsWidgets,
    );
    expect(find.text('Open Android overlay settings'), findsOneWidget);
  });

  testWidgets('home screen refreshes the state when the app resumes', (
    tester,
  ) async {
    final service = FakeOverlayService(state: _state(permission: false));
    await _pumpApp(tester, service);
    expect(
      find.textContaining('Overlay permission is not granted'),
      findsWidgets,
    );

    service.state = _state(enabled: true, running: true);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.textContaining('is running'), findsOneWidget);
  });

  testWidgets('enabling the button in settings starts the service', (
    tester,
  ) async {
    final service = FakeOverlayService(state: _state());
    await _pumpApp(tester, service);
    await _openSettings(tester);

    await tester.tap(find.byKey(const Key('floating-button-switch')));
    await tester.pumpAndSettle();

    expect(service.setEnabledCalls, <bool>[true]);
    expect(find.text('Overlay permission granted'), findsOneWidget);
  });

  testWidgets('disabling the button in settings stops the service', (
    tester,
  ) async {
    final service = FakeOverlayService(
      state: _state(enabled: true, running: true),
    );
    await _pumpApp(tester, service);
    await _openSettings(tester);

    await tester.tap(find.byKey(const Key('floating-button-switch')));
    await tester.pumpAndSettle();

    expect(service.setEnabledCalls, <bool>[false]);
  });

  testWidgets('settings shows an error when the overlay cannot start', (
    tester,
  ) async {
    final service = FakeOverlayService(
      state: _state(permission: false),
      refuseEnableWith: OverlayStartException.permissionMissing,
    );
    await _pumpApp(tester, service);
    await _openSettings(tester);

    await tester.tap(find.byKey(const Key('floating-button-switch')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('overlay-message')), findsOneWidget);
    expect(find.textContaining('Display over other apps'), findsWidgets);
    // The toggle must not claim the button is on when Android refused.
    final tile = tester.widget<SwitchListTile>(
      find.byKey(const Key('floating-button-switch')),
    );
    expect(tile.value, isFalse);
  });

  testWidgets('settings links to the Android overlay permission screen', (
    tester,
  ) async {
    final service = FakeOverlayService(state: _state(permission: false));
    await _pumpApp(tester, service);
    await _openSettings(tester);

    await tester.tap(find.byKey(const Key('open-overlay-settings')));
    await tester.pumpAndSettle();

    expect(service.openOverlaySettingsCalls, 1);
  });
}
