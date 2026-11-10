import 'package:flutter/foundation.dart';

@immutable
final class StreetViewPanoramaLink {
  const StreetViewPanoramaLink({required this.bearing, required this.panoId});

  factory StreetViewPanoramaLink.fromJson(List<Object?> json) =>
      StreetViewPanoramaLink(
        panoId: json[0]! as String,
        bearing: (json[1]! as num).toDouble(),
      );

  /// The direction of the linked panorama, in degrees clockwise from north.
  final double bearing;

  /// The panorama ID of the linked panorama.
  final String panoId;

  @override
  bool operator ==(Object other) =>
      other is StreetViewPanoramaLink &&
      other.bearing == bearing &&
      other.panoId == panoId;

  @override
  int get hashCode => Object.hash(bearing, panoId);

  @override
  String toString() =>
      'StreetViewPanoramaLink(bearing: $bearing, panoId: $panoId)';
}
