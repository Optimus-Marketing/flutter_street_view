import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

import '../places.dart';

class OptionsDemo extends StatefulWidget {
  const OptionsDemo({super.key});

  @override
  State<OptionsDemo> createState() => _OptionsDemoState();
}

class _OptionsDemoState extends State<OptionsDemo> {
  StreetViewController? _controller;

  Future<void> _update(Future<void> Function() change) async {
    await change();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: Column(
        children: [
          Expanded(
            child: FlutterGoogleStreetView(
              initPos: sydney,
              onStreetViewCreated: (controller) =>
                  setState(() => _controller = controller),
            ),
          ),
          if (controller != null)
            SafeArea(
              top: false,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Street names'),
                    value: controller.isStreetNamesEnabled,
                    onChanged: (enabled) => _update(
                      () => controller.setStreetNamesEnabled(enabled),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Navigation'),
                    value: controller.isUserNavigationEnabled,
                    onChanged: (enabled) => _update(
                      () => controller.setUserNavigationEnabled(enabled),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Zoom gestures'),
                    value: controller.isZoomGesturesEnabled,
                    onChanged: (enabled) => _update(
                      () => controller.setZoomGesturesEnabled(enabled),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Panning gestures'),
                    value: controller.isPanningGesturesEnabled,
                    onChanged: (enabled) => _update(
                      () => controller.setPanningGesturesEnabled(enabled),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
