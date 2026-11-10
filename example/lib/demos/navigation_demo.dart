import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

import '../places.dart';

class NavigationDemo extends StatefulWidget {
  const NavigationDemo({super.key});

  @override
  State<NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationDemo> {
  static const _degreesPerStep = 30.0;
  static const _zoomPerStep = 0.5;

  StreetViewController? _controller;
  double _animationMilliseconds = 600;

  Future<void> _moveCamera({
    double bearing = 0,
    double tilt = 0,
    double zoom = 0,
  }) async {
    final controller = _controller;
    if (controller == null) return;
    final camera = await controller.getPanoramaCamera();
    await controller.animateTo(
      camera: StreetViewPanoramaCamera(
        bearing: (camera.bearing ?? 0) + bearing,
        tilt: (camera.tilt ?? 0) + tilt,
        zoom: (camera.zoom ?? 0) + zoom,
      ),
      duration: _animationMilliseconds.round(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Navigation')),
    body: Column(
      children: [
        Expanded(
          child: FlutterGoogleStreetView(
            initPos: sydney,
            onStreetViewCreated: (controller) =>
                setState(() => _controller = controller),
          ),
        ),
        if (_controller case final controller?)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.outlined(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _moveCamera(bearing: -_degreesPerStep),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () => _moveCamera(tilt: _degreesPerStep),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: () => _moveCamera(tilt: -_degreesPerStep),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _moveCamera(bearing: _degreesPerStep),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.zoom_in),
                        onPressed: () => _moveCamera(zoom: _zoomPerStep),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.zoom_out),
                        onPressed: () => _moveCamera(zoom: -_zoomPerStep),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Animation'),
                      Expanded(
                        child: Slider(
                          value: _animationMilliseconds,
                          min: 1,
                          max: 2000,
                          onChanged: (value) =>
                              setState(() => _animationMilliseconds = value),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            controller.setPosition(position: sydney),
                        child: const Text('Sydney'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            controller.setPosition(position: sanFrancisco),
                        child: const Text('San Francisco'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            controller.setPosition(panoId: santoriniPanoId),
                        child: const Text('Santorini'),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.setPosition(
                          position: locationWithoutPanorama,
                        ),
                        child: const Text('No panorama'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
