enum StreetViewSource {
  /// Default: Uses the default sources of Street View,
  /// searches will not be limited to specific sources.
  def('default'),

  /// Limits Street View searches to outdoor collections.
  outdoor('outdoor');

  const StreetViewSource(this._json);

  final String _json;

  String toJson() => _json;
}
