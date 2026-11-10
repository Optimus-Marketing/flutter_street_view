import 'package:flutter/foundation.dart';

import 'bitmap_descriptor.dart';
import 'lat_lng.dart';

/// Uniquely identifies a [Marker] among [FlutterGoogleStreetView] markers.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
final class MarkerId {
  /// Creates an immutable identifier for a [Marker].
  const MarkerId(this.value);

  /// The value of the id.
  final String value;

  @override
  bool operator ==(Object other) => other is MarkerId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MarkerId($value)';
}

/// Marks a geographical location on the street view.
@immutable
final class Marker {
  /// Creates a set of marker configuration options.
  ///
  /// Default marker options.
  ///
  /// Specifies a marker that
  /// * has a default icon; [icon] is `BitmapDescriptor.defaultMarker`
  /// * is positioned at 0, 0; [position] is `LatLng(0.0, 0.0)`
  /// * is visible; [visible] is true
  /// * reports [onTap] events
  const Marker({
    required this.markerId,
    this.icon = BitmapDescriptor.defaultMarker,
    this.position = const LatLng(0.0, 0.0),
    this.visible = true,
    this.onTap,
  });

  /// Uniquely identifies a [Marker].
  final MarkerId markerId;

  /// A description of the bitmap used to draw the marker icon.
  final BitmapDescriptor icon;

  /// Geographical location of the marker.
  final LatLng position;

  /// True if the marker is visible.
  final bool visible;

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Marker] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Marker copyWith({
    BitmapDescriptor? icon,
    LatLng? position,
    bool? visible,
    VoidCallback? onTap,
  }) => Marker(
    markerId: markerId,
    icon: icon ?? this.icon,
    position: position ?? this.position,
    visible: visible ?? this.visible,
    onTap: onTap ?? this.onTap,
  );

  /// Converts this object to something serializable in JSON.
  Map<String, Object> toJson() => {
    'markerId': markerId.value,
    'icon': icon.toJson(),
    'position': position.toJson(),
    'visible': visible,
  };

  @override
  bool operator ==(Object other) =>
      other is Marker &&
      other.markerId == markerId &&
      other.icon == icon &&
      other.position == position &&
      other.visible == visible;

  @override
  int get hashCode => Object.hash(markerId, icon, position, visible);

  @override
  String toString() =>
      'Marker(markerId: $markerId, icon: $icon, position: $position, visible: $visible)';
}
