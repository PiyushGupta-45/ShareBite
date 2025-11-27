import 'dart:math';

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

  // Calculate distance from user's location (in km) using Haversine formula
  double distanceFrom(double userLat, double userLon) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _toRadians(latitude - userLat);
    final double dLon = _toRadians(longitude - userLon);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) * cos(_toRadians(latitude)) *
        sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}

