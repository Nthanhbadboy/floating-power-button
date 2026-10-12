import 'package:flutter/material.dart';

import 'overlay/overlay_controller.dart';
import 'overlay/overlay_service.dart';
import 'ui/home_screen.dart';

/// Root widget. [overlayService] is injectable so tests can run without the
/// Android platform channel.
class FloatingPowerButtonApp extends StatefulWidget {
  const FloatingPowerButtonApp({super.key, this.overlayService});

  final OverlayService? overlayService;

  @override
  State<FloatingPowerButtonApp> createState() => _FloatingPowerButtonAppState();
}

class _FloatingPowerButtonAppState extends State<FloatingPowerButtonApp> {
  late final OverlayController _controller = OverlayController(
    widget.overlayService ?? const MethodChannelOverlayService(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Power Button',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: HomeScreen(controller: _controller),
    );
  }
}
