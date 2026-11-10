import 'package:flutter/foundation.dart';

@immutable
final class StreetViewPanoramaOrientation {
  const StreetViewPanoramaOrientation({
    required this.bearing,
    required this.tilt,
  });

  /// Create [StreetViewPanoramaOrientation] and put data by [map].
  factory StreetViewPanoramaOrientation.fromMap(Map<Object?, Object?> map) =>
      StreetViewPanoramaOrientation(
        bearing: (map['bearing']! as num).toDouble(),
        tilt: (map['tilt']! as num).toDouble(),
      );

  /// Direction of the orientation, in degrees clockwise from north.
  final double bearing;

  /// The angle, in degrees, of the orientation.
  final double tilt;

  /// Put all param to a map
  Map<String, double> toMap() => {'bearing': bearing, 'tilt': tilt};

  @override
  bool operator ==(Object other) =>
      other is StreetViewPanoramaOrientation &&
      other.bearing == bearing &&
      other.tilt == tilt;

  @override
  int get hashCode => Object.hash(bearing, tilt);

  @override
  String toString() =>
      'StreetViewPanoramaOrientation(bearing: $bearing, tilt: $tilt)';
}
