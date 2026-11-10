import 'street_view.dart';
import 'types/lat_lng.dart';
import 'types/street_view_source.dart';

final class StreetViewOptions {
  StreetViewOptions.fromWidget(FlutterGoogleStreetView widget)
    : _values = {
        'panoId': widget.initPanoId,
        'position': widget.initPos,
        'radius': widget.initRadius,
        'source': widget.initSource,
        'bearing': widget.initBearing,
        'tilt': widget.initTilt,
        'zoom': widget.initZoom,
        'fov': widget.initFov,
        'panningGesturesEnabled': widget.panningGesturesEnabled,
        'streetNamesEnabled': widget.streetNamesEnabled,
        'userNavigationEnabled': widget.userNavigationEnabled,
        'zoomGesturesEnabled': widget.zoomGesturesEnabled,
        'hasCameraChangeListener': widget.onCameraChangeListener != null,
        'hasPanoramaChangeListener': widget.onPanoramaChangeListener != null,
        'hasPanoramaClickListener': widget.onPanoramaClickListener != null,
        'hasPanoramaLongClickListener':
            widget.onPanoramaLongClickListener != null,
      };

  final Map<String, Object?> _values;

  Map<String, Object> toCreationParams() => _encode(_values);

  Map<String, Object> changesSince(StreetViewOptions previous) => _encode({
    for (final MapEntry(:key, :value) in _values.entries)
      if (value != previous._values[key]) key: value,
  });

  static Map<String, Object> _encode(Map<String, Object?> values) => {
    for (final MapEntry(:key, :value) in values.entries)
      if (value != null)
        key: switch (value) {
          LatLng() => value.toJson(),
          StreetViewSource() => value.toJson(),
          _ => value,
        },
  };
}
