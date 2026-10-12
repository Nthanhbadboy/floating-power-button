import 'package:flutter_test/flutter_test.dart';
import 'package:floating_power_button/src/overlay/overlay_controller.dart';
import 'package:floating_power_button/src/overlay/overlay_service.dart';

import 'helpers/fake_overlay_service.dart';

void main() {
  OverlayStatus state({
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

  group('OverlayController', () {
    test('starts from the unknown state and reports it honestly', () {
      final controller = OverlayController(FakeOverlayService(state: state()));

      expect(controller.status, const OverlayStatus.unknown());
      expect(controller.isVisible, isFalse);
      expect(controller.message, isNull);
    });

    test('refresh exposes the native state', () async {
      final controller = OverlayController(
        FakeOverlayService(state: state(enabled: true, running: true)),
      );

      await controller.refresh();

      expect(controller.overlayPermissionGranted, isTrue);
      expect(controller.enabled, isTrue);
      expect(controller.isVisible, isTrue);
      expect(controller.busy, isFalse);
    });

    test('enabling starts the overlay service', () async {
      final service = FakeOverlayService(state: state());
      final controller = OverlayController(service);

      final applied = await controller.setEnabled(true);

      expect(applied, isTrue);
      expect(service.setEnabledCalls, <bool>[true]);
      expect(controller.isVisible, isTrue);
      expect(controller.message, isNull);
    });

    test('disabling stops the overlay service', () async {
      final service = FakeOverlayService(
        state: state(enabled: true, running: true),
      );
      final controller = OverlayController(service);

      final applied = await controller.setEnabled(false);

      expect(applied, isTrue);
      expect(controller.enabled, isFalse);
      expect(controller.isVisible, isFalse);
    });

    test(
      'reports a missing overlay permission instead of claiming success',
      () async {
        final service = FakeOverlayService(
          state: state(permission: false),
          refuseEnableWith: OverlayStartException.permissionMissing,
        );
        final controller = OverlayController(service);

        final applied = await controller.setEnabled(true);

        expect(applied, isFalse);
        expect(controller.message, contains('Display over other apps'));
        expect(controller.enabled, isFalse);
        expect(controller.isVisible, isFalse);
      },
    );

    test('reports a generic service start failure', () async {
      final service = FakeOverlayService(
        state: state(),
        refuseEnableWith: OverlayStartException.startFailed,
      );
      final controller = OverlayController(service);

      final applied = await controller.setEnabled(true);

      expect(applied, isFalse);
      expect(controller.message, isNotNull);
      expect(controller.message, isNot(contains('Display over other apps')));
    });

    test(
      'revoked permission makes the button not visible even when enabled',
      () async {
        final service = FakeOverlayService(
          state: state(permission: false, enabled: true, running: false),
        );
        final controller = OverlayController(service);

        await controller.refresh();

        expect(controller.enabled, isTrue);
        expect(controller.overlayPermissionGranted, isFalse);
        expect(controller.isVisible, isFalse);
      },
    );

    test(
      'openOverlaySettings reports when no system screen handled the intent',
      () async {
        final service = FakeOverlayService(
          state: state(),
          settingsScreenOpens: false,
        );
        final controller = OverlayController(service);

        final opened = await controller.openOverlaySettings();

        expect(opened, isFalse);
        expect(service.openOverlaySettingsCalls, 1);
        expect(controller.message, contains('Android settings'));
      },
    );

    test('notifies listeners when the state changes', () async {
      final service = FakeOverlayService(state: state());
      final controller = OverlayController(service);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.setEnabled(true);

      expect(notifications, greaterThan(0));
    });
  });
}
