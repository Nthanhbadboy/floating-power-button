import 'package:flutter/material.dart';

import '../overlay/overlay_controller.dart';
import 'settings_screen.dart';

/// Milestone 1 home screen: shows the overlay status and links to Settings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final OverlayController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
    // The user may have granted or revoked the overlay permission in Android
    // settings while the app was in the background, so never assume a past grant.
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
      appBar: AppBar(title: const Text('Floating Power Button')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Floating button status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_statusText()),
                  if (!_controller.overlayPermissionGranted) ...<Widget>[
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: _controller.busy
                          ? null
                          : () => _controller.openOverlaySettings(),
                      child: const Text('Open Android overlay settings'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(controller: _controller),
              ),
            ),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  String _statusText() {
    if (!_controller.overlayPermissionGranted) {
      return 'Overlay permission is not granted. The floating button cannot be '
          'shown until you enable "Display over other apps" for this app.';
    }
    if (_controller.isVisible) {
      return 'The floating button is running and can be dragged over other '
          'applications.';
    }
    if (_controller.enabled) {
      return 'The floating button is enabled but not running right now.';
    }
    return 'The floating button is disabled. Enable it in Settings.';
  }
}
