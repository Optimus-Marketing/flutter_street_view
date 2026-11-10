import 'types/marker.dart';

final class MarkerUpdates {
  MarkerUpdates.from(
    Map<MarkerId, Marker> previous,
    Map<MarkerId, Marker> current,
  ) : markersToAdd = [
        for (final MapEntry(key: id, value: marker) in current.entries)
          if (!previous.containsKey(id)) marker,
      ],
      markersToChange = [
        for (final MapEntry(key: id, value: marker) in current.entries)
          if (previous.containsKey(id) && previous[id] != marker) marker,
      ],
      markerIdsToRemove = [
        for (final id in previous.keys)
          if (!current.containsKey(id)) id,
      ];

  final List<Marker> markersToAdd;
  final List<Marker> markersToChange;
  final List<MarkerId> markerIdsToRemove;

  bool get isEmpty =>
      markersToAdd.isEmpty &&
      markersToChange.isEmpty &&
      markerIdsToRemove.isEmpty;

  Map<String, Object> toJson() => {
    'markersToAdd': [for (final marker in markersToAdd) marker.toJson()],
    'markersToChange': [for (final marker in markersToChange) marker.toJson()],
    'markerIdsToRemove': [for (final id in markerIdsToRemove) id.value],
  };
}
