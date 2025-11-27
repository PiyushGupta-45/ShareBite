class AnalyticsInsight {
  const AnalyticsInsight({
    required this.metric,
    required this.value,
    required this.unit,
    required this.trendPercent,
    required this.description,
  });

  final String metric;
  final double value;
  final String unit;
  final double trendPercent;
  final String description;
}

