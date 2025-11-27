import 'dart:math' as math;

class DeliveryRun {
  const DeliveryRun({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.restaurantAddress,
    required this.restaurantLatitude,
    required this.restaurantLongitude,
    required this.restaurantPhone,
    required this.ngoId,
    required this.ngoName,
    required this.ngoLocation,
    required this.ngoAddress,
    required this.ngoLatitude,
    required this.ngoLongitude,
    required this.ngoPhone,
    required this.pickupTime,
    required this.deliveryTime,
    required this.numberOfMeals,
    required this.status,
    this.description,
    this.urgencyTag,
  });

  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantLocation;
  final String restaurantAddress;
  final double restaurantLatitude;
  final double restaurantLongitude;
  final String restaurantPhone;
  final String ngoId;
  final String ngoName;
  final String ngoLocation;
  final String ngoAddress;
  final double ngoLatitude;
  final double ngoLongitude;
  final String ngoPhone;
  final DateTime pickupTime;
  final DateTime deliveryTime;
  final int numberOfMeals;
  final String status; // 'pending', 'accepted', 'in_progress', 'completed'
  final String? description;
  final String? urgencyTag; // 'Urgent', 'Flex', etc.

  bool get isUrgent => urgencyTag?.toLowerCase().contains('urgent') ?? false;
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted' || status == 'in_progress';

  // Calculate distance from restaurant to NGO
  double get distanceKm {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _toRadians(ngoLatitude - restaurantLatitude);
    final double dLon = _toRadians(ngoLongitude - restaurantLongitude);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(restaurantLatitude)) * math.cos(_toRadians(ngoLatitude)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

