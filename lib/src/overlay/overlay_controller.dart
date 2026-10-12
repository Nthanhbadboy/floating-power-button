import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'overlay_service.dart';

/// Single source of truth for the overlay state used by the UI.
///
/// Milestone 1 scope: read the native state, start/stop the overlay
/// deterministically, and surface failures honestly (no silent "it worked").
class OverlayController extends ChangeNotifier {
  OverlayController(this._service);

  final OverlayService _service;

  OverlayStatus _status = const OverlayStatus.unknown();
  bool _busy = false;
  String? _message;

  OverlayStatus get status => _status;
  bool get overlayPermissionGranted => _status.overlayPermissionGranted;
  bool get enabled => _status.enabled;
  bool get isVisible => _status.isVisible;

  /// A native call is in flight; inputs are disabled meanwhile.
  bool get busy => _busy;

  /// Last user-facing error, or null when the last operation succeeded.
  String? get message => _message;

  /// Re-reads the native state (called on start and when returning to the app,
  /// because the overlay permission can change while the app is in the
  /// background).
  Future<void> refresh() async {
    _busy = true;
    try {
      await _reloadStatus();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Returns true when the requested state was applied by Android.
  Future<bool> setEnabled(bool value) async {
    _busy = true;
    _message = null;
    notifyListeners();
    var applied = false;
    try {
      await _service.setEnabled(value);
      applied = true;
    } on OverlayStartException catch (error) {
      _message = switch (error.code) {
        OverlayStartException.permissionMissing =>
          'The floating button needs the "Display over other apps" permission. '
              'Grant it in Android settings, then enable the button again.',
        _ =>
          'Android could not start the floating button service, so it was not '
              'enabled.',
      };
    } on MissingPluginException {
      _message =
          'The overlay bridge is unavailable on this platform build. The '
          'floating button was not started.';
    } on PlatformException catch (error) {
      _message =
          'Android reported "${error.code}" while changing the floating button '
          'state.';
    }
    await _reloadStatus();
    _busy = false;
    notifyListeners();
    return applied;
  }

  /// Opens the system "Display over other apps" screen.
  Future<bool> openOverlaySettings() async {
    _message = null;
    try {
      final opened = await _service.openOverlaySettings();
      if (!opened) {
        _message =
            'This device did not open the "Display over other apps" screen. '
            'Enable it manually in Android settings.';
      }
      notifyListeners();
      return opened;
    } on MissingPluginException {
      _message = 'The overlay bridge is unavailable on this platform build.';
      notifyListeners();
      return false;
    } on PlatformException catch (error) {
      _message =
          'Android reported "${error.code}" while opening the overlay '
          'permission screen.';
      notifyListeners();
      return false;
    }
  }

  Future<void> _reloadStatus() async {
    try {
      _status = await _service.getState();
    } on MissingPluginException {
      _message ??= 'The overlay bridge is unavailable on this platform build.';
    } on PlatformException catch (error) {
      _message ??=
          'Android reported "${error.code}" while reading the overlay state.';
    }
  }
}
