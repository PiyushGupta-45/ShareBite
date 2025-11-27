class Run {
  const Run({
    required this.id,
    required this.donorName,
    required this.pickupLocation,
    required this.dropLocation,
    required this.readyBy,
    required this.expiresAt,
    required this.distanceKm,
    required this.isUrgent,
    required this.isFlexible,
    required this.isTonight,
  });

  final String id;
  final String donorName;
  final String pickupLocation;
  final String dropLocation;
  final DateTime readyBy;
  final DateTime expiresAt;
  final double distanceKm;
  final bool isUrgent;
  final bool isFlexible;
  final bool isTonight;

  String get route => '$pickupLocation → $dropLocation';

  Duration get timeLeft => expiresAt.difference(DateTime.now());
}

