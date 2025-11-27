import 'dart:math';

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    this.image,
    this.description,
    this.website,
  });

  final String id;
  final String name;
  final String location; // Area/district
  final String address; // Full address
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final String? image;
  final String? description;
  final String? website;

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

