import 'package:flutter/services.dart';

/// Snapshot of the native overlay state.
///
/// Mirrors the map returned by `OverlayController.state()` in
/// `android/app/src/main/kotlin/.../overlay/OverlayController.kt`.
class OverlayStatus {
  const OverlayStatus({
    required this.overlayPermissionGranted,
    required this.enabled,
    required this.serviceRunning,
  });

  /// Safe default used before the native state has been read once.
  const OverlayStatus.unknown()
    : overlayPermissionGranted = false,
      enabled = false,
      serviceRunning = false;

  /// "Display over other apps" (SYSTEM_ALERT_WINDOW) is currently granted.
  final bool overlayPermissionGranted;

  /// The user asked for the floating button to be shown.
  final bool enabled;

  /// The overlay service is actually running right now.
  final bool serviceRunning;

  /// The button is only really on screen when all three hold.
  bool get isVisible => overlayPermissionGranted && enabled && serviceRunning;

  @override
  String toString() =>
      'OverlayStatus(permission: $overlayPermissionGranted, '
      'enabled: $enabled, running: $serviceRunning)';
}

/// Thrown when Android refuses to start the overlay service.
class OverlayStartException implements Exception {
  const OverlayStartException(this.code);

  /// `SYSTEM_ALERT_WINDOW` is not granted, so no window can be added.
  static const String permissionMissing = 'overlay_permission_missing';

  /// Anything else (for example the service could not be started).
  static const String startFailed = 'overlay_start_failed';

  final String code;

  @override
  String toString() => 'OverlayStartException($code)';
}

/// Native overlay bridge used by the UI layer.
abstract interface class OverlayService {
  /// Reads the current permission / service state.
  Future<OverlayStatus> getState();

  /// Enables or disables the floating button. Throws [OverlayStartException]
  /// when Android refuses (for example: permission not granted).
  Future<void> setEnabled(bool enabled);

  /// Opens the system screen where the overlay permission is granted.
  /// Returns false when no activity could handle the intent.
  Future<bool> openOverlaySettings();
}

/// [OverlayService] implementation on top of the platform channel exposed by
/// `MainActivity`.
class MethodChannelOverlayService implements OverlayService {
  const MethodChannelOverlayService([
    this._channel = const MethodChannel('floating_power_button/overlay'),
  ]);

  final MethodChannel _channel;

  @override
  Future<OverlayStatus> getState() async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'getState',
    );
    if (result == null) {
      throw PlatformException(
        code: 'empty_state',
        message: 'The platform returned no overlay state.',
      );
    }
    return OverlayStatus(
      overlayPermissionGranted: result['overlayPermissionGranted'] == true,
      enabled: result['enabled'] == true,
      serviceRunning: result['serviceRunning'] == true,
    );
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'setEnabled',
      <String, Object?>{'enabled': enabled},
    );
    final ok = result?['ok'] == true;
    if (!ok) {
      throw OverlayStartException(
        (result?['error'] as String?) ?? OverlayStartException.startFailed,
      );
    }
  }

  @override
  Future<bool> openOverlaySettings() async {
    return await _channel.invokeMethod<bool>('openOverlaySettings') ?? false;
  }
}
