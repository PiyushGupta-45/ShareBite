class LogisticsAlert {
  const LogisticsAlert({
    required this.donorName,
    required this.location,
    required this.radiusKm,
    required this.urgencyTag,
    required this.expiry,
    required this.requiresRefrigeration,
  });

  final String donorName;
  final String location;
  final double radiusKm;
  final String urgencyTag;
  final DateTime expiry;
  final bool requiresRefrigeration;
}

