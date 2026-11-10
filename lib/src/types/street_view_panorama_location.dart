import 'package:flutter/foundation.dart';

import 'lat_lng.dart';
import 'street_view_panorama_link.dart';

@immutable
final class StreetViewPanoramaLocation {
  const StreetViewPanoramaLocation({
    required this.links,
    required this.position,
    required this.panoId,
  });

  static StreetViewPanoramaLocation? fromMap(Map<Object?, Object?>? map) {
    if (map == null) return null;
    final position = LatLng.fromJson(map['position']);
    final panoId = map['panoId'] as String?;
    if (position == null || panoId == null) return null;
    final links = map['links'] as List<Object?>? ?? const [];
    return StreetViewPanoramaLocation(
      links: [
        for (final link in links)
          StreetViewPanoramaLink.fromJson(link! as List<Object?>),
      ],
      position: position,
      panoId: panoId,
    );
  }

  /// Array [StreetViewPanoramaLink] includes information about near panoramas of current panorama.
  final List<StreetViewPanoramaLink> links;

  /// The location of current panorama.
  final LatLng position;

  /// The panorama Id of current panorama.
  final String panoId;

  @override
  bool operator ==(Object other) =>
      other is StreetViewPanoramaLocation &&
      listEquals(other.links, links) &&
      other.position == position &&
      other.panoId == panoId;

  @override
  int get hashCode => Object.hash(Object.hashAll(links), position, panoId);

  @override
  String toString() =>
      'StreetViewPanoramaLocation(links: $links, position: $position, panoId: $panoId)';
}
