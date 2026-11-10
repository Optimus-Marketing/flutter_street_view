import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

import '../places.dart';

class InitDemo extends StatefulWidget {
  const InitDemo({super.key});

  @override
  State<InitDemo> createState() => _InitDemoState();
}

class _InitDemoState extends State<InitDemo> {
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;

  Future<void> _toggleMarkerIcon() async {
    if (_markerIcon != BitmapDescriptor.defaultMarker) {
      setState(() => _markerIcon = BitmapDescriptor.defaultMarker);
      return;
    }
    final bytes = await DefaultAssetBundle.of(
      context,
    ).load('assets/images/ic_dot.png');
    setState(
      () =>
          _markerIcon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Initial options')),
    body: FlutterGoogleStreetView(
      initPos: sanFrancisco,
      initSource: StreetViewSource.outdoor,
      initBearing: 30,
      zoomGesturesEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('dot'),
          position: sanFrancisco,
          icon: _markerIcon,
          onTap: _toggleMarkerIcon,
        ),
      },
    ),
  );
}
