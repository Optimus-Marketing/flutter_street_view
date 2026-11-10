import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

import '../places.dart';

class EventsDemo extends StatefulWidget {
  const EventsDemo({super.key});

  @override
  State<EventsDemo> createState() => _EventsDemoState();
}

class _EventsDemoState extends State<EventsDemo> {
  StreetViewController? _controller;
  String _camera = 'Camera: -';
  String _panorama = 'Panorama: -';
  String _tap = 'Tap: -';
  String _longPress = 'Long press: -';

  void _onCameraChange(StreetViewPanoramaCamera camera) => setState(
    () => _camera =
        'Camera: bearing ${camera.bearing?.toStringAsFixed(1)}, '
        'tilt ${camera.tilt?.toStringAsFixed(1)}, '
        'zoom ${camera.zoom?.toStringAsFixed(1)}',
  );

  void _onPanoramaChange(StreetViewPanoramaLocation? location, Exception? e) =>
      setState(
        () => _panorama = location == null
            ? 'Panorama: $e'
            : 'Panorama: ${location.panoId} at ${location.position}',
      );

  String _describeTap(
    StreetViewPanoramaOrientation orientation,
    Point<int> point,
  ) =>
      'bearing ${orientation.bearing.toStringAsFixed(1)}, '
      'tilt ${orientation.tilt.toStringAsFixed(1)} at (${point.x}, ${point.y})';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Events')),
    body: Stack(
      children: [
        FlutterGoogleStreetView(
          initPos: sydney,
          onStreetViewCreated: (controller) =>
              setState(() => _controller = controller),
          onCameraChangeListener: _onCameraChange,
          onPanoramaChangeListener: _onPanoramaChange,
          onPanoramaClickListener: (orientation, point) =>
              setState(() => _tap = 'Tap: ${_describeTap(orientation, point)}'),
          onPanoramaLongClickListener: (orientation, point) => setState(
            () =>
                _longPress = 'Long press: ${_describeTap(orientation, point)}',
          ),
        ),
        if (_controller case final controller?)
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(_camera),
                  Text(_panorama),
                  Text(_tap),
                  Text(_longPress),
                  OutlinedButton(
                    onPressed: () => controller.setPosition(
                      position: locationWithoutPanorama,
                    ),
                    child: const Text('Go to a location without panorama'),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
