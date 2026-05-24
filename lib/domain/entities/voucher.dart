class Voucher {
  const Voucher({
    required this.id,
    required this.title,
    required this.code,
    required this.pointsRequired,
    this.description,
    this.discountValue,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String code;
  final int pointsRequired;
  final String? description;
  final String? discountValue;
  final bool isActive;

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: (json['id'] ?? json['_id']) as String,
      title: json['title'] as String,
      code: json['code'] as String,
      pointsRequired: (json['pointsRequired'] as num).toInt(),
      description: json['description'] as String?,
      discountValue: json['discountValue'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
