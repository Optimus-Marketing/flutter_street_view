import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_native_street_view.dart';

const _sydney = LatLng(-33.87365, 151.20689);
const _sanFrancisco = LatLng(37.769263, -122.450727);

void main() {
  Future<void> pumpStreetView(
    WidgetTester tester,
    FlutterGoogleStreetView streetView,
  ) async {
    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: streetView),
    );
    await tester.pump();
  }

  testWidgets('sends the initial options as creation params', (tester) async {
    final native = FakeNativeStreetView(tester)..install();

    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        initSource: StreetViewSource.outdoor,
        initBearing: 30,
        zoomGesturesEnabled: false,
        onCameraChangeListener: (_) {},
        markers: {const Marker(markerId: MarkerId('church'))},
      ),
    );

    expect(native.creationParams, {
      'position': [_sydney.latitude, _sydney.longitude],
      'source': 'outdoor',
      'bearing': 30.0,
      'streetNamesEnabled': true,
      'userNavigationEnabled': true,
      'zoomGesturesEnabled': false,
      'hasCameraChangeListener': true,
      'hasPanoramaChangeListener': false,
      'hasPanoramaClickListener': false,
      'hasPanoramaLongClickListener': false,
    });
  });

  testWidgets('creates the controller once the native view is ready', (
    tester,
  ) async {
    final native = FakeNativeStreetView(tester)..install();
    native.readyState = Completer()
      ..complete(
        FakeNativeStreetView.readyStateWith(
          zoomGesturesEnabled: false,
          streetViewCount: 2,
        ),
      );
    StreetViewController? controller;

    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        onStreetViewCreated: (created) => controller = created,
      ),
    );

    expect(controller?.viewId, native.viewId);
    expect(controller?.isZoomGesturesEnabled, isFalse);
    expect(FlutterGoogleStreetView.createdCount, 2);
  });

  testWidgets('sends only the options that changed', (tester) async {
    final native = FakeNativeStreetView(tester)..install();
    await pumpStreetView(
      tester,
      const FlutterGoogleStreetView(initPos: _sydney, initBearing: 30),
    );

    await pumpStreetView(
      tester,
      const FlutterGoogleStreetView(
        initPos: _sanFrancisco,
        initBearing: 30,
        streetNamesEnabled: false,
      ),
    );

    expect(native.callsTo('streetView#updateOptions').single.arguments, {
      'position': [_sanFrancisco.latitude, _sanFrancisco.longitude],
      'streetNamesEnabled': false,
    });
  });

  testWidgets('sends the changes made before the native view was ready', (
    tester,
  ) async {
    final native = FakeNativeStreetView(tester)..install();
    native.readyState = Completer();
    await pumpStreetView(
      tester,
      const FlutterGoogleStreetView(initPos: _sydney),
    );

    await pumpStreetView(
      tester,
      const FlutterGoogleStreetView(initPos: _sydney, initTilt: 15),
    );
    expect(native.callsTo('streetView#updateOptions'), isEmpty);

    native.readyState.complete(FakeNativeStreetView.readyStateWith());
    await tester.pump();

    expect(native.callsTo('streetView#updateOptions').single.arguments, {
      'tilt': 15.0,
    });
  });

  testWidgets('forwards native events to the widget callbacks', (tester) async {
    final native = FakeNativeStreetView(tester)..install();
    final events = <Object?>[];
    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        onCameraChangeListener: events.add,
        onPanoramaChangeListener: (location, error) =>
            events.add(location ?? error.toString()),
        onPanoramaClickListener: (orientation, point) =>
            events.add((orientation, point)),
        onPanoramaLongClickListener: (orientation, point) =>
            events.add(('long', orientation, point)),
      ),
    );

    await native.sendEvent('camera#onChange', {'bearing': 1.0, 'zoom': 2.0});
    await native.sendEvent('pano#onChange', {
      'panoId': 'pano',
      'position': [_sydney.latitude, _sydney.longitude],
      'links': [
        ['next', 90.0],
      ],
    });
    await native.sendEvent('pano#onChange', {'error': 'No panorama'});
    await native.sendEvent('pano#onClick', {
      'bearing': 3.0,
      'tilt': 4.0,
      'x': 5,
      'y': 6,
    });
    await native.sendEvent('pano#onLongClick', {
      'bearing': 7.0,
      'tilt': 8.0,
      'x': 9,
      'y': 10,
    });

    expect(events, [
      const StreetViewPanoramaCamera(bearing: 1, zoom: 2),
      const StreetViewPanoramaLocation(
        links: [StreetViewPanoramaLink(bearing: 90, panoId: 'next')],
        position: _sydney,
        panoId: 'pano',
      ),
      'Exception: No panorama',
      (
        const StreetViewPanoramaOrientation(bearing: 3, tilt: 4),
        const Point(5, 6),
      ),
      (
        'long',
        const StreetViewPanoramaOrientation(bearing: 7, tilt: 8),
        const Point(9, 10),
      ),
    ]);
  });

  testWidgets('uses the latest callbacks after the widget updates', (
    tester,
  ) async {
    final native = FakeNativeStreetView(tester)..install();
    final cameras = <StreetViewPanoramaCamera>[];
    await pumpStreetView(
      tester,
      const FlutterGoogleStreetView(initPos: _sydney),
    );

    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        onCameraChangeListener: cameras.add,
      ),
    );
    await native.sendEvent('camera#onChange', {'bearing': 1.0});

    expect(cameras, [const StreetViewPanoramaCamera(bearing: 1)]);
    expect(native.callsTo('streetView#updateOptions').single.arguments, {
      'hasCameraChangeListener': true,
    });
  });

  testWidgets('sends iOS markers and their updates', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final native = FakeNativeStreetView(tester)..install();
    var tappedMarkers = 0;
    final church = Marker(
      markerId: const MarkerId('church'),
      position: _sydney,
      onTap: () => tappedMarkers++,
    );
    const cross = Marker(markerId: MarkerId('cross'));
    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(initPos: _sydney, markers: {church, cross}),
    );

    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        markers: {
          church.copyWith(visible: false),
          const Marker(markerId: MarkerId('altar')),
        },
      ),
    );
    await native.sendEvent('marker#onTap', {'markerId': 'church'});
    debugDefaultTargetPlatformOverride = null;

    expect(native.creationParams?['markersToAdd'], [
      church.toJson(),
      cross.toJson(),
    ]);
    expect(native.callsTo('markers#update').single.arguments, {
      'markersToAdd': [const Marker(markerId: MarkerId('altar')).toJson()],
      'markersToChange': [church.copyWith(visible: false).toJson()],
      'markerIdsToRemove': ['cross'],
    });
    expect(tappedMarkers, 1);
  });

  testWidgets('encodes controller commands for the native view', (
    tester,
  ) async {
    final native = FakeNativeStreetView(tester)..install();
    native.location = {
      'panoId': 'pano',
      'position': [_sydney.latitude, _sydney.longitude],
      'links': <Object?>[],
    };
    late StreetViewController controller;
    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        onStreetViewCreated: (created) => controller = created,
      ),
    );

    await controller.animateTo(
      camera: const StreetViewPanoramaCamera(bearing: 90),
      duration: 500,
    );
    await controller.setPosition(panoId: 'pano', radius: 50);
    await controller.setZoomGesturesEnabled(false);

    expect(controller.isZoomGesturesEnabled, isFalse);
    expect(native.calls.skip(1).map((call) => [call.method, call.arguments]), [
      [
        'streetView#animateTo',
        {'bearing': 90.0, 'duration': 500},
      ],
      [
        'streetView#updateOptions',
        {'panoId': 'pano', 'radius': 50},
      ],
      [
        'streetView#updateOptions',
        {'zoomGesturesEnabled': false},
      ],
    ]);
    expect(
      await controller.getLocation(),
      const StreetViewPanoramaLocation(
        links: [],
        position: _sydney,
        panoId: 'pano',
      ),
    );
    expect(
      await controller.getPanoramaCamera(),
      const StreetViewPanoramaCamera(bearing: 10, tilt: 5),
    );
    expect(
      await controller.orientationToPoint(
        const StreetViewPanoramaOrientation(bearing: 1, tilt: 2),
      ),
      const Point(12, 34),
    );
    expect(
      await controller.pointToOrientation(const Point(1.4, 2.6)),
      const StreetViewPanoramaOrientation(bearing: 90, tilt: -10),
    );
    expect(native.calls.last.arguments, {'x': 1, 'y': 3});
  });

  testWidgets('stops forwarding native events after dispose', (tester) async {
    final native = FakeNativeStreetView(tester)..install();
    final cameras = <StreetViewPanoramaCamera>[];
    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        onCameraChangeListener: cameras.add,
      ),
    );

    await tester.pumpWidget(const SizedBox());
    await native.sendEvent('camera#onChange', {'bearing': 1.0});

    expect(cameras, isEmpty);
  });

  testWidgets('skips onStreetViewCreated when disposed before ready', (
    tester,
  ) async {
    final native = FakeNativeStreetView(tester)..install();
    native.readyState = Completer();
    var createdControllers = 0;
    await pumpStreetView(
      tester,
      FlutterGoogleStreetView(
        initPos: _sydney,
        onStreetViewCreated: (_) => createdControllers++,
      ),
    );

    await tester.pumpWidget(const SizedBox());
    native.readyState.complete(null);
    await tester.pump();

    expect(createdControllers, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes before the native view is created', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      (call) async => call.method == 'create' ? Completer<int>().future : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        null,
      ),
    );

    await pumpStreetView(
      tester,
      const FlutterGoogleStreetView(initPanoId: 'WddsUw1geEoAAAQIt9RnsQ'),
    );
    await tester.pumpWidget(const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
