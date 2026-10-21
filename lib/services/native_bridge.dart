import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceInfo {
  const DeviceInfo({
    required this.manufacturer,
    required this.brand,
    required this.model,
  });

  final String manufacturer;
  final String brand;
  final String model;

  String get displayName {
    final m = manufacturer.trim();
    final capitalized =
        m.isEmpty ? 'Android' : '${m[0].toUpperCase()}${m.substring(1)}';
    return model.trim().isEmpty ? capitalized : '$capitalized ($model)';
  }
}

/// All Android platform calls live behind this bridge so the Dart side never
/// starts a service / opens a settings screen "implicitly".
class NativeBridge {
  const NativeBridge._();

  static const MethodChannel _channel =
      MethodChannel('power_volume/native');

  static Future<T?> _invoke<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null; // e.g. widget tests / non-Android platforms
    } on PlatformException catch (e) {
      debugPrint('NativeBridge.$method failed: ${e.message}');
      return null;
    }
  }

  static Future<DeviceInfo> getDeviceInfo() async {
    final map = await _invoke<Map<dynamic, dynamic>>('getDeviceInfo');
    return DeviceInfo(
      manufacturer: map?['manufacturer']?.toString() ?? '',
      brand: map?['brand']?.toString() ?? '',
      model: map?['model']?.toString() ?? '',
    );
  }

  static Future<bool> isAccessibilityEnabled() async =>
      await _invoke<bool>('isAccessibilityEnabled') ?? false;

  static Future<void> openAccessibilitySettings() =>
      _invoke<void>('openAccessibilitySettings');

  static Future<bool> isDeviceAdminActive() async =>
      await _invoke<bool>('isDeviceAdminActive') ?? false;

  static Future<void> requestDeviceAdmin() =>
      _invoke<void>('requestDeviceAdmin');

  static Future<bool> isIgnoringBatteryOptimizations() async =>
      await _invoke<bool>('isIgnoringBatteryOptimizations') ?? false;

  static Future<void> requestIgnoreBatteryOptimizations() =>
      _invoke<void>('requestIgnoreBatteryOptimizations');

  static Future<void> openAppDetailsSettings() =>
      _invoke<void>('openAppDetailsSettings');

  /// Opens the OEM "App launch / Autostart / Battery" screen for [guideId]
  /// (see ManufacturerGuides). Falls back to App Info on stock Android.
  static Future<void> openManufacturerSettings(String guideId) =>
      _invoke<void>('openManufacturerSettings', {'guideId': guideId});

  /// Instant lock via Accessibility GLOBAL_ACTION_LOCK_SCREEN, falling back
  /// to Device Admin `lockNow()`. Returns false when neither is available.
  static Future<bool> lockScreen() async =>
      await _invoke<bool>('lockScreen') ?? false;

  static Future<void> showVolumePanel() => _invoke<void>('showVolumePanel');

  /// IMPORTANT (review issue #4): this must ONLY be called after the user
  /// confirmed the explanation dialog. Never call it from initState() for a
  /// fresh install.
  static Future<bool> startForegroundService() async =>
      await _invoke<bool>('startForegroundService') ?? false;

  static Future<void> stopForegroundService() =>
      _invoke<void>('stopForegroundService');

  static Future<bool> isForegroundServiceRunning() async =>
      await _invoke<bool>('isForegroundServiceRunning') ?? false;
}
