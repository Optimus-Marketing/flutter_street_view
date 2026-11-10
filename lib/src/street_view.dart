import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'marker_updates.dart';
import 'street_view_options.dart';
import 'types/callbacks.dart';
import 'types/lat_lng.dart';
import 'types/marker.dart';
import 'types/street_view_panorama_camera.dart';
import 'types/street_view_panorama_location.dart';
import 'types/street_view_panorama_orientation.dart';
import 'types/street_view_source.dart';

part 'street_view_controller.dart';

class FlutterGoogleStreetView extends StatefulWidget {
  const FlutterGoogleStreetView({
    super.key,
    this.onStreetViewCreated,
    this.onCameraChangeListener,
    this.onPanoramaChangeListener,
    this.onPanoramaClickListener,
    this.onPanoramaLongClickListener,
    this.initPanoId,
    this.initPos,
    this.initRadius,
    this.initSource,
    this.initFov,
    this.initBearing,
    this.initTilt,
    this.initZoom,
    this.panningGesturesEnabled,
    this.streetNamesEnabled = true,
    this.userNavigationEnabled = true,
    this.zoomGesturesEnabled,
    this.gestureRecognizers,
    this.markers,
  }) : assert((initPanoId != null) ^ (initPos != null)),
       assert(initTilt == null || (initTilt >= -90 && initTilt <= 90));

  /// Specifies initialization position by panoramaID.
  /// [initPos] should be null while [initPanoId] was set.
  final String? initPanoId;

  /// Specifies initialization position by latitude and longitude.
  /// [initPanoId] should be null while [initPos] was set.
  final LatLng? initPos;

  /// Specifies radius used to search for a Street View panorama
  final double? initRadius;

  /// Specifies the source filter used to search for a Street View panorama,
  /// or DEFAULT if unspecified.
  final StreetViewSource? initSource;

  /// Specifies bearing for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// Sets the direction that the camera is pointing in, in degrees clockwise from north.
  final double? initBearing;

  /// Specifies tilt for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// This value is restricted to being between -90 (directly down) and 90 (directly up).
  final double? initTilt;

  /// Specifies zoom for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// Sets the zoom level of the camera. The original zoom level is set at 0.
  /// A zoom of 1 would double the magnification. The zoom is clamped between 0 and the maximum zoom level.
  /// The maximum zoom level can vary based upon the panorama.
  /// Clamped means that any value falling outside this range will be set to the closest extreme that falls within the range.
  /// For example, a value of -1 will be set to 0.
  /// Another example: If the maximum zoom for the panorama is 19,
  /// and the value is given as 20, it will be set to 19.
  /// Note that the camera zoom need not be an integer value.
  final double? initZoom;

  /// The field of view (FOV) encompassed by the larger dimension (width or height) of the view in degrees at zoom 1. `iOS only`
  /// This is clamped to the range [1, 160] degrees, and has a default value of 90.
  /// Lower FOV values produce a zooming in effect; larger FOV values produce an fisheye effect.
  final double? initFov;

  /// Sets whether the user is able to use panning gestures.
  final bool? panningGesturesEnabled;

  /// Sets whether the user is able to see street names on panoramas
  final bool streetNamesEnabled;

  /// Sets whether the user is able to move to another panorama
  final bool userNavigationEnabled;

  /// Sets whether the user is able to use zoom gestures.
  final bool? zoomGesturesEnabled;

  /// Callback method for when the street view is ready to be used.
  ///
  /// Used to receive a [StreetViewController] for this [FlutterGoogleStreetView].
  final StreetViewCreatedCallback? onStreetViewCreated;
  final CameraChangeListener? onCameraChangeListener;
  final PanoramaChangeListener? onPanoramaChangeListener;
  final PanoramaClickListener? onPanoramaClickListener;
  final PanoramaLongClickListener? onPanoramaLongClickListener;

  /// Markers to be placed on the street view. `iOS only`
  final Set<Marker>? markers;

  /// Which gestures should be consumed by the streetView.
  ///
  /// It is possible for other gesture recognizers to be competing with the streetView on pointer
  /// events, e.g if the streetView is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The street view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the street view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// The created count of native street view.
  static int get createdCount => StreetViewController._nativeStreetViewCount;

  @override
  State<FlutterGoogleStreetView> createState() =>
      _FlutterGoogleStreetViewState();
}

class _FlutterGoogleStreetViewState extends State<FlutterGoogleStreetView> {
  late StreetViewOptions _options = StreetViewOptions.fromWidget(widget);
  late Map<MarkerId, Marker> _markers = _markersById(widget.markers);
  late final Map<String, Object> _creationParams = {
    ..._options.toCreationParams(),
    if (_supportsMarkers)
      'markersToAdd': [for (final marker in _markers.values) marker.toJson()],
  };
  StreetViewController? _controller;

  bool get _supportsMarkers => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void didUpdateWidget(FlutterGoogleStreetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller case final controller? when controller._isReady) {
      _syncNativeView(controller);
    }
  }

  @override
  void dispose() {
    _controller?._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _StreetViewPlatformView(
    creationParams: _creationParams,
    gestureRecognizers: widget.gestureRecognizers,
    onPlatformViewCreated: _onPlatformViewCreated,
  );

  Future<void> _onPlatformViewCreated(int viewId) async {
    final controller = _controller = StreetViewController._(viewId, this);
    await controller._waitUntilReady();
    if (!mounted || !controller._isReady) return;
    _syncNativeView(controller);
    widget.onStreetViewCreated?.call(controller);
  }

  void _syncNativeView(StreetViewController controller) {
    final options = StreetViewOptions.fromWidget(widget);
    final optionChanges = options.changesSince(_options);
    _options = options;
    if (optionChanges.isNotEmpty) {
      unawaited(controller._updateOptions(optionChanges));
    }

    if (!_supportsMarkers) return;
    final markers = _markersById(widget.markers);
    final markerUpdates = MarkerUpdates.from(_markers, markers);
    _markers = markers;
    if (!markerUpdates.isEmpty) {
      unawaited(controller._updateMarkers(markerUpdates));
    }
  }

  void _onMarkerTap(MarkerId markerId) => _markers[markerId]?.onTap?.call();

  static Map<MarkerId, Marker> _markersById(Set<Marker>? markers) => {
    for (final marker in markers ?? const <Marker>{}) marker.markerId: marker,
  };
}

class _StreetViewPlatformView extends StatelessWidget {
  const _StreetViewPlatformView({
    required this.creationParams,
    required this.gestureRecognizers,
    required this.onPlatformViewCreated,
  });

  static const _viewType = 'flutter_google_street_view';

  final Map<String, Object> creationParams;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final PlatformViewCreatedCallback onPlatformViewCreated;

  @override
  Widget build(BuildContext context) => switch (defaultTargetPlatform) {
    TargetPlatform.android => PlatformViewLink(
      viewType: _viewType,
      surfaceFactory: (context, controller) => AndroidViewSurface(
        controller: controller as AndroidViewController,
        gestureRecognizers: gestureRecognizers ?? const {},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
      onCreatePlatformView: (params) =>
          PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: _viewType,
              layoutDirection:
                  Directionality.maybeOf(context) ?? TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create(),
    ),
    TargetPlatform.iOS => UiKitView(
      viewType: _viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: gestureRecognizers,
      onPlatformViewCreated: onPlatformViewCreated,
    ),
    _ => Text(
      '$defaultTargetPlatform is not supported by '
      'flutter_google_street_view',
    ),
  };
}
