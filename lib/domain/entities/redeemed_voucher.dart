class RedeemedVoucher {
  const RedeemedVoucher({
    required this.code,
    required this.title,
    required this.pointsUsed,
    required this.redeemedAt,
  });

  final String code;
  final String title;
  final int pointsUsed;
  final DateTime redeemedAt;

  factory RedeemedVoucher.fromJson(Map<String, dynamic> json) {
    return RedeemedVoucher(
      code: json['code'] as String,
      title: json['title'] as String,
      pointsUsed: (json['pointsUsed'] as num).toInt(),
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
    );
  }
}
