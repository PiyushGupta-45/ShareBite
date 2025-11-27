class NGO {
  const NGO({
    required this.id,
    required this.name,
    required this.tagline,
    required this.mainImage,
    required this.images,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String tagline;
  final String mainImage; // URL or asset path
  final List<String> images; // Multiple images for detail view
  final String description;
  final String location; // Address or area name
  final double latitude;
  final double longitude;

  // Calculate distance from user's location (in km)
  double distanceFrom(double userLat, double userLon) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _toRadians(latitude - userLat);
    final double dLon = _toRadians(longitude - userLon);
    
    final double a = (dLat / 2) * (dLat / 2) +
        _toRadians(userLat) * _toRadians(latitude) *
        (dLon / 2) * (dLon / 2);
    final double c = 2 * (a * a).abs().sqrt().asin();
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}

