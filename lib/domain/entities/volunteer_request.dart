class VolunteerRequest {
  const VolunteerRequest({
    required this.id,
    required this.pickupPoint,
    required this.dropOffPoint,
    required this.payloadType,
    required this.distanceKm,
    required this.readyBy,
    required this.highPriority,
  });

  final String id;
  final String pickupPoint;
  final String dropOffPoint;
  final String payloadType;
  final double distanceKm;
  final DateTime readyBy;
  final bool highPriority;
}

