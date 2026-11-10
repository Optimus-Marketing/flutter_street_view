import 'package:flutter/foundation.dart';

@immutable
final class StreetViewPanoramaCamera {
  const StreetViewPanoramaCamera({
    this.bearing,
    this.tilt,
    this.zoom,
    this.fov,
  });

  factory StreetViewPanoramaCamera.fromMap(Map<Object?, Object?> map) =>
      StreetViewPanoramaCamera(
        bearing: (map['bearing'] as num?)?.toDouble(),
        tilt: (map['tilt'] as num?)?.toDouble(),
        zoom: (map['zoom'] as num?)?.toDouble(),
        fov: (map['fov'] as num?)?.toDouble(),
      );

  ///Direction of the orientation, in degrees clockwise from north.
  final double? bearing;

  /// The angle in degrees from horizon of the panorama, range -90 to 90
  final double? tilt;

  /// The zoom level of current panorama.
  /// more info see,
  /// for [android] https://developers.google.com/android/reference/com/google/android/gms/maps/model/StreetViewPanoramaCamera.Builder#zoom
  /// for [iOS] https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_camera#adb2250d57b30987cd2d13e52fa03833d
  final double? zoom;

  /// The field of view (FOV) encompassed by the larger dimension (width or height) of the view in degrees at zoom 1. `iOS only`
  /// This is clamped to the range [1, 160] degrees, and has a default value of 90.
  /// more info see, [iOS] https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_panorama_camera#a64dcd1302c83a54f2d068cbb19ea5cef
  final double? fov;

  Map<String, double> toMap() => {
    'bearing': ?bearing,
    'tilt': ?tilt,
    'zoom': ?zoom,
    'fov': ?fov,
  };

  @override
  bool operator ==(Object other) =>
      other is StreetViewPanoramaCamera &&
      other.bearing == bearing &&
      other.tilt == tilt &&
      other.zoom == zoom &&
      other.fov == fov;

  @override
  int get hashCode => Object.hash(bearing, tilt, zoom, fov);

  @override
  String toString() =>
      'StreetViewPanoramaCamera(bearing: $bearing, tilt: $tilt, zoom: $zoom, fov: $fov)';
}
