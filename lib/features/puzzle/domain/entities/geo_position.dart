class GeoPosition {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeName;

  const GeoPosition({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeName,
  });

  double distanceTo(GeoPosition other) {
    // Simplified distance calculation
    final lat1 = latitude;
    final lon1 = longitude;
    final lat2 = other.latitude;
    final lon2 = other.longitude;

    // Simple Euclidean distance (not accurate for real geo distances)
    return ((lat2 - lat1) * (lat2 - lat1) + (lon2 - lon1) * (lon2 - lon1));
  }

  bool isWithinRadius(GeoPosition other, double radiusInMeters) {
    return distanceTo(other) <= radiusInMeters;
  }
}
