import 'package:flutter/material.dart';

import '../overlay/overlay_controller.dart';

/// Milestone 1 settings screen: enable/disable the floating button and manage
/// the overlay permission. Function selection is added in Milestone 2.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final OverlayController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  OverlayController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
    _controller.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.refresh();
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Floating button',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The button is drawn on top of other apps, so Android requires the '
            '"Display over other apps" permission. The permission is granted by '
            'you in Android settings and can be revoked at any time.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            key: const Key('floating-button-switch'),
            title: const Text('Show floating button'),
            subtitle: const Text(
              'Drag the button anywhere; its position is remembered.',
            ),
            value: _controller.enabled,
            onChanged: _controller.busy
                ? null
                : (value) => _controller.setEnabled(value),
          ),
          const SizedBox(height: 8),
          _PermissionRow(
            granted: _controller.overlayPermissionGranted,
            busy: _controller.busy,
            onOpenSettings: _controller.openOverlaySettings,
          ),
          if (_controller.message != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              _controller.message!,
              key: const Key('overlay-message'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.granted,
    required this.busy,
    required this.onOpenSettings,
  });

  final bool granted;
  final bool busy;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    if (granted) {
      return Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('Overlay permission granted')),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Overlay permission is not granted')),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('open-overlay-settings'),
          onPressed: busy ? null : () => onOpenSettings(),
          child: const Text('Grant it in Android settings'),
        ),
      ],
    );
  }
}
