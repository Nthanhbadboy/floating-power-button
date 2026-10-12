import 'package:floating_power_button/src/overlay/overlay_service.dart';

/// Test double for the native overlay bridge.
class FakeOverlayService implements OverlayService {
  FakeOverlayService({
    required this.state,
    this.refuseEnableWith,
    this.settingsScreenOpens = true,
  });

  OverlayStatus state;

  /// When set, enabling the button throws [OverlayStartException] with this code.
  String? refuseEnableWith;

  /// Result of opening the system overlay-permission screen.
  bool settingsScreenOpens;

  /// Every [setEnabled] call, in order.
  final List<bool> setEnabledCalls = <bool>[];

  int openOverlaySettingsCalls = 0;

  @override
  Future<OverlayStatus> getState() async => state;

  @override
  Future<void> setEnabled(bool enabled) async {
    setEnabledCalls.add(enabled);
    if (enabled && refuseEnableWith != null) {
      throw OverlayStartException(refuseEnableWith!);
    }
    final canShow = state.overlayPermissionGranted;
    state = OverlayStatus(
      overlayPermissionGranted: canShow,
      enabled: enabled,
      serviceRunning: enabled && canShow,
    );
  }

  @override
  Future<bool> openOverlaySettings() async {
    openOverlaySettingsCalls++;
    return settingsScreenOpens;
  }
}
