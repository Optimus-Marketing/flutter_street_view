part of 'street_view.dart';

class StreetViewController {
  StreetViewController._(this.viewId, this._streetView)
    : _channel = MethodChannel('flutter_google_street_view_$viewId') {
    _channel.setMethodCallHandler(_handleNativeEvent);
  }

  static int _nativeStreetViewCount = 0;

  final int viewId;
  final MethodChannel _channel;
  final _FlutterGoogleStreetViewState _streetView;
  bool _isReady = false;
  bool _isPanningGesturesEnabled = true;
  bool _isStreetNamesEnabled = true;
  bool _isUserNavigationEnabled = true;
  bool _isZoomGesturesEnabled = true;

  /// Return street view is able to use panning gestures.
  bool get isPanningGesturesEnabled => _isPanningGesturesEnabled;

  /// Return street view is displaying street name or not.
  bool get isStreetNamesEnabled => _isStreetNamesEnabled;

  /// Return street view is able user move to another panorama.
  bool get isUserNavigationEnabled => _isUserNavigationEnabled;

  /// Return street view is able to use zoom gestures.
  bool get isZoomGesturesEnabled => _isZoomGesturesEnabled;

  /// Animate camera to a given position over a specified duration.
  ///
  /// [duration] unit is ms.
  ///
  /// Return [Future] while the change has been started on the platform side.
  Future<void> animateTo({
    required StreetViewPanoramaCamera camera,
    required int duration,
  }) {
    assert(duration > 0);
    return _channel.invokeMethod('streetView#animateTo', {
      ...camera.toMap(),
      'duration': duration,
    });
  }

  /// Return position of current panorama and information of near panoramas
  Future<StreetViewPanoramaLocation?> getLocation() async =>
      StreetViewPanoramaLocation.fromMap(
        await _channel.invokeMapMethod('streetView#getLocation'),
      );

  /// Return camera setting, bearing, tilt and zoom.
  Future<StreetViewPanoramaCamera> getPanoramaCamera() async =>
      StreetViewPanoramaCamera.fromMap(
        (await _channel.invokeMapMethod('streetView#getPanoramaCamera'))!,
      );

  /// Returns a screen location that corresponds to an orientation[StreetViewPanoramaOrientation].
  Future<Point<int>?> orientationToPoint(
    StreetViewPanoramaOrientation orientation,
  ) async {
    final point = await _channel.invokeMapMethod<Object?, Object?>(
      'streetView#orientationToPoint',
      orientation.toMap(),
    );
    return point == null ? null : _pointFrom(point);
  }

  /// Return the orientation[StreetViewPanoramaOrientation] that corresponds to a screen location.
  Future<StreetViewPanoramaOrientation?> pointToOrientation(
    Point<num> point,
  ) async {
    final orientation = await _channel.invokeMapMethod<Object?, Object?>(
      'streetView#pointToOrientation',
      {'x': point.x.round(), 'y': point.y.round()},
    );
    return orientation == null
        ? null
        : StreetViewPanoramaOrientation.fromMap(orientation);
  }

  /// Sets panorama by given location
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPosition({
    LatLng? position,
    String? panoId,
    int? radius,
    StreetViewSource? source,
  }) {
    assert((position != null) ^ (panoId != null));
    return _updateOptions({
      'position': ?position?.toJson(),
      'panoId': ?panoId,
      'radius': ?radius,
      'source': ?source?.toJson(),
    });
  }

  /// Sets street view to allow using panning gesture or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanningGesturesEnabled(bool enable) =>
      _updateOptions({'panningGesturesEnabled': enable});

  /// Sets street view to display street name or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setStreetNamesEnabled(bool enable) =>
      _updateOptions({'streetNamesEnabled': enable});

  /// Sets street view to allow moving to another panorama.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setUserNavigationEnabled(bool enable) =>
      _updateOptions({'userNavigationEnabled': enable});

  /// Sets street view to allow using zoom gestures or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomGesturesEnabled(bool enable) =>
      _updateOptions({'zoomGesturesEnabled': enable});

  Future<void> _waitUntilReady() async {
    final state = await _channel.invokeMapMethod<String, Object?>(
      'streetView#waitForStreetView',
    );
    if (state == null) return;
    _rememberGestures(state);
    _nativeStreetViewCount = state['streetViewCount']! as int;
    _isReady = true;
  }

  Future<void> _updateOptions(Map<String, Object> changes) async {
    await _channel.invokeMethod<void>('streetView#updateOptions', changes);
    _rememberGestures(changes);
  }

  Future<void> _updateMarkers(MarkerUpdates updates) =>
      _channel.invokeMethod<void>('markers#update', updates.toJson());

  void _rememberGestures(Map<String, Object?> state) {
    if (state['panningGesturesEnabled'] case final bool enabled) {
      _isPanningGesturesEnabled = enabled;
    }
    if (state['streetNamesEnabled'] case final bool enabled) {
      _isStreetNamesEnabled = enabled;
    }
    if (state['userNavigationEnabled'] case final bool enabled) {
      _isUserNavigationEnabled = enabled;
    }
    if (state['zoomGesturesEnabled'] case final bool enabled) {
      _isZoomGesturesEnabled = enabled;
    }
  }

  void _dispose() => _channel.setMethodCallHandler(null);

  Future<void> _handleNativeEvent(MethodCall call) async {
    final widget = _streetView.widget;
    final arguments = call.arguments as Map<Object?, Object?>;
    switch (call.method) {
      case 'camera#onChange':
        widget.onCameraChangeListener?.call(
          StreetViewPanoramaCamera.fromMap(arguments),
        );
      case 'pano#onChange':
        final error = arguments['error'] as String?;
        widget.onPanoramaChangeListener?.call(
          error == null ? StreetViewPanoramaLocation.fromMap(arguments) : null,
          error == null ? null : Exception(error),
        );
      case 'pano#onClick':
        widget.onPanoramaClickListener?.call(
          StreetViewPanoramaOrientation.fromMap(arguments),
          _pointFrom(arguments),
        );
      case 'pano#onLongClick':
        widget.onPanoramaLongClickListener?.call(
          StreetViewPanoramaOrientation.fromMap(arguments),
          _pointFrom(arguments),
        );
      case 'marker#onTap':
        _streetView._onMarkerTap(MarkerId(arguments['markerId']! as String));
      default:
        throw MissingPluginException(
          '${call.method} is not handled by flutter_google_street_view',
        );
    }
  }

  static Point<int> _pointFrom(Map<Object?, Object?> map) =>
      Point(map['x']! as int, map['y']! as int);
}
