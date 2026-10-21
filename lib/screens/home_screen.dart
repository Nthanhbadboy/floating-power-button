import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_info.dart';
import '../data/manufacturer_guides.dart';
import '../models/manufacturer_guide.dart';
import '../l10n/app_strings.dart';
import '../services/native_bridge.dart';
import '../services/preferences_service.dart';
import '../widgets/foreground_service_dialog.dart';
import 'privacy_policy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.preferences});

  final PreferencesService preferences;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late String _code = widget.preferences.languageCode;
  AppStrings get _s => AppStrings(_code);

  DeviceInfo _device = const DeviceInfo(manufacturer: '', brand: '', model: '');
  String? _detectedGuideId;
  late String _selectedGuideId = 'huawei';
  bool _guideExpanded = false;

  bool _accessibilityActive = false;
  bool _deviceAdminActive = false;
  bool _ignoringBattery = false;

  /// Review issue #4: defaults to FALSE on a fresh install
  /// (see PreferencesService.keepAliveEnabled).
  bool _keepAliveEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _keepAliveEnabled = widget.preferences.keepAliveEnabled;
    _refreshStatus(resumeConsentedService: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshStatus();
  }

  Future<void> _refreshStatus({bool resumeConsentedService = false}) async {
    final results = await Future.wait<Object?>([
      NativeBridge.getDeviceInfo(),
      NativeBridge.isAccessibilityEnabled(),
      NativeBridge.isDeviceAdminActive(),
      NativeBridge.isIgnoringBatteryOptimizations(),
      NativeBridge.isForegroundServiceRunning(),
    ]);
    if (!mounted) return;
    final device = results[0] as DeviceInfo;
    final detected =
        ManufacturerGuides.detect(device.manufacturer, device.brand);
    setState(() {
      _device = device;
      _accessibilityActive = results[1] as bool;
      _deviceAdminActive = results[2] as bool;
      _ignoringBattery = results[3] as bool;
      if (detected != null) {
        _detectedGuideId = detected.id;
        _selectedGuideId = detected.id;
      }
      // The switch reflects reality, not just the stored preference.
      _keepAliveEnabled =
          widget.preferences.keepAliveEnabled && (results[4] as bool ||
              widget.preferences.hasForegroundServiceConsent);
    });

    // Resume ONLY a service the user previously switched on AND confirmed
    // in the consent dialog. A fresh install never reaches this branch
    // because both persisted flags default to false.
    if (resumeConsentedService &&
        widget.preferences.keepAliveEnabled &&
        widget.preferences.hasForegroundServiceConsent &&
        !(results[4] as bool)) {
      await NativeBridge.startForegroundService();
    }
  }

  // --- Review issue #4 -------------------------------------------------------
  Future<void> _onKeepAliveToggled(bool value) async {
    if (!value) {
      await NativeBridge.stopForegroundService();
      await widget.preferences.setKeepAliveEnabled(false);
      if (!mounted) return;
      setState(() => _keepAliveEnabled = false);
      _snack(_s.t('fgStopped'));
      return;
    }

    // Turning ON: explain first, start only after explicit "Enable".
    final confirmed = await showForegroundServiceConsentDialog(context, _s);
    if (!confirmed || !mounted) {
      setState(() => _keepAliveEnabled = false);
      return;
    }
    final started = await NativeBridge.startForegroundService();
    if (!mounted) return;
    if (started) {
      await widget.preferences.setKeepAliveEnabled(true);
      setState(() => _keepAliveEnabled = true);
      _snack(_s.t('fgStarted'));
    } else {
      setState(() => _keepAliveEnabled = false);
      _snack(_s.t('fgStartFailed'));
    }
  }

  Future<void> _lockScreen() async {
    final ok = await NativeBridge.lockScreen();
    if (!ok && mounted) {
      _snack(_s.t('lockNeedsAccessibility'));
      await NativeBridge.openAccessibilitySettings();
    }
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _changeLanguage(String code) async {
    await widget.preferences.setLanguageCode(code);
    if (mounted) setState(() => _code = code);
  }

  @override
  Widget build(BuildContext context) {
    final guide = ManufacturerGuides.byId(_selectedGuideId);
    final isProtected = _accessibilityActive || _keepAliveEnabled;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshStatus(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _protectionBanner(isProtected),
                    const SizedBox(height: 16),
                    _guideCard(guide),
                    if (_guideExpanded) ...[
                      const SizedBox(height: 12),
                      _guideInstructions(guide),
                    ],
                    const SizedBox(height: 16),
                    _lockVolumeRow(),
                    const SizedBox(height: 16),
                    _permissionsCard(),
                    const SizedBox(height: 16),
                    _supportCard(),
                    const SizedBox(height: 12),
                    _adPlaceholder(),
                    const SizedBox(height: 8),
                    _footerLinks(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/icon/app_icon_114.png',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_s.t('appTitle'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          PopupMenuButton<String>(
            initialValue: _code,
            onSelected: _changeLanguage,
            itemBuilder: (_) => [
              for (final code in AppStrings.supportedCodes)
                PopupMenuItem(
                    value: code, child: Text(AppStrings.languageName(code))),
            ],
            child: Chip(
              avatar: const Icon(Icons.language, size: 18),
              label: Text(AppStrings.languageName(_code)),
            ),
          ),
          IconButton(
            tooltip: 'Support',
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () =>
                launchUrl(Uri.parse('mailto:${AppInfo.contactEmail}')),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStatus(),
          ),
        ],
      ),
    );
  }

  Widget _protectionBanner(bool isProtected) {
    final MaterialColor color = isProtected ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(
                    isProtected ? Icons.shield : Icons.shield_outlined,
                    color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _s.t(isProtected
                          ? 'protectedTitle'
                          : 'notProtectedTitle'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color.shade800),
                    ),
                    Text('Device: ${_device.displayName}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_s
              .t(isProtected ? 'protectedBody' : 'notProtectedBody')
              .replaceAll('{device}', _device.displayName)),
        ],
      ),
    );
  }

  Widget _guideCard(ManufacturerGuide guide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        border: Border.all(color: const Color(0xFF90CAF9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_suggest, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_s.t('guideCardTitle'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1565C0))),
                    Text(_device.displayName,
                        style: const TextStyle(color: Color(0xFF1E88E5))),
                  ],
                ),
              ),
              const Chip(label: Text('Anti-Kill')),
            ],
          ),
          const SizedBox(height: 8),
          Text(_s.t('guideCardBody')),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: Icon(_guideExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              label: Text(
                  _s.t(_guideExpanded ? 'hideInstructions' : 'viewInstructions')),
              onPressed: () =>
                  setState(() => _guideExpanded = !_guideExpanded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guideInstructions(ManufacturerGuide guide) {
    final steps = ManufacturerGuides.byId(_selectedGuideId).stepsFor(_code);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s.t('guideAutoDetect')),
            const SizedBox(height: 12),
            // OEM tabs: Huawei | Xiaomi | Samsung | OPPO | Vivo
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final g in ManufacturerGuides.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: g.id == _selectedGuideId,
                        showCheckmark: g.id == _selectedGuideId,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(g.displayName),
                            if (g.id == _detectedGuideId) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(_s.t('yourDevice'),
                                    style: const TextStyle(fontSize: 10)),
                              ),
                            ],
                          ],
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedGuideId = g.id),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _s
                  .t('setupStepsFor')
                  .replaceAll('{brand}', guide.displayName),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('${i + 1}. ${steps[i]}'),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF263238)),
                icon: const Icon(Icons.open_in_new),
                label: Text(ManufacturerGuides.byId(_selectedGuideId)
                    .settingsButtonFor(_code)),
                onPressed: () => NativeBridge.openManufacturerSettings(
                    _selectedGuideId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockVolumeRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _bigActionCard(
            colors: const [Color(0xFFE53935), Color(0xFFC62828)],
            icon: Icons.power_settings_new,
            title: _s.t('lockScreen'),
            subtitle: _s.t('lockScreenSub'),
            onTap: _lockScreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _bigActionCard(
            colors: const [Color(0xFF1E88E5), Color(0xFF1565C0)],
            icon: Icons.volume_up,
            title: _s.t('volumePanel'),
            subtitle: _s.t('volumePanelSub'),
            onTap: NativeBridge.showVolumePanel,
          ),
        ),
      ],
    );
  }

  Widget _bigActionCard({
    required List<Color> colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _permissionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Color(0xFF1E88E5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_s.t('permissionsTitle'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _permissionRow(
              icon: Icons.accessibility_new,
              iconBg: const Color(0xFFE3F2FD),
              title: _s.t('accessibility'),
              subtitle: _s.t(_accessibilityActive
                  ? 'accessibilityActive'
                  : 'accessibilityInactive'),
              subtitleColor: _accessibilityActive ? Colors.green : Colors.red,
              trailing: _accessibilityActive
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.chevron_right),
              onTap: NativeBridge.openAccessibilitySettings,
            ),
            const Divider(),
            _permissionRow(
              icon: Icons.shield,
              iconBg: const Color(0xFFE0F2F1),
              title: _s.t('deviceAdmin'),
              subtitle: _s.t(_deviceAdminActive
                  ? 'deviceAdminActive'
                  : 'deviceAdminInactive'),
              subtitleColor: _deviceAdminActive ? Colors.green : Colors.red,
              trailing: const Icon(Icons.chevron_right),
              onTap: NativeBridge.requestDeviceAdmin,
            ),
            const Divider(),
            // Review issue #4 — the switch itself. Default OFF; turning it
            // ON always goes through the explanation dialog first.
            _permissionRow(
              icon: Icons.bolt,
              iconBg: const Color(0xFFFFF3E0),
              title: _s.t('keepAliveTitle'),
              subtitle: _s.t('keepAliveSubtitle'),
              subtitleColor: Colors.grey.shade700,
              trailing: Switch(
                value: _keepAliveEnabled,
                onChanged: _onKeepAliveToggled,
              ),
              onTap: () => _onKeepAliveToggled(!_keepAliveEnabled),
            ),
            const Divider(),
            _permissionRow(
              icon: Icons.battery_charging_full,
              iconBg: const Color(0xFFE8F5E9),
              title: _s.t('ignoreBattery'),
              subtitle:
                  _s.t(_ignoringBattery ? 'ignoreBatteryOff' : 'ignoreBatteryOn'),
              subtitleColor: _ignoringBattery ? Colors.green : Colors.red,
              trailing: const Icon(Icons.chevron_right),
              onTap: NativeBridge.requestIgnoreBatteryOptimizations,
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.blueGrey.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: subtitleColor)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _supportCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFFE082)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.coffee, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_s.t('supportTitle'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_s.t('supportBody')),
          ],
        ),
      ),
    );
  }

  Widget _adPlaceholder() {
    // AdMob / Petal Ads banner mounts here in release builds. Kept as a
    // clearly-labelled placeholder so no ad SDK runs before privacy consent.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Chip(label: const Text('Ad')),
          const SizedBox(width: 8),
          Expanded(child: Text(_s.t('adsNote'))),
          const Icon(Icons.info_outline, size: 18),
        ],
      ),
    );
  }

  Widget _footerLinks() {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PrivacyPolicyScreen(initialLanguageCode: _code),
                ),
              ),
              child: Text(_s.t('privacyPolicy')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TermsOfServiceScreen(languageCode: _code),
                ),
              ),
              child: Text(_s.t('termsOfService')),
            ),
          ],
        ),
        Text(
          '${AppInfo.shortAppName} v${AppInfo.version} • ${AppInfo.developerName}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
