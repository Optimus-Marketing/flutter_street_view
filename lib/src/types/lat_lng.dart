import 'package:flutter/foundation.dart';

@immutable
final class LatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive)
  const LatLng(double latitude, double longitude)
    : latitude = latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude),
      longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  /// Converts this object to something serializable in JSON.
  List<double> toJson() => [latitude, longitude];

  /// Initialize a LatLng from an \[lat, lng\] array.
  static LatLng? fromJson(Object? json) => switch (json) {
    [final num latitude, final num longitude] => LatLng(
      latitude.toDouble(),
      longitude.toDouble(),
    ),
    _ => null,
  };

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
