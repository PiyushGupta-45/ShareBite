class NGODemand {
  const NGODemand({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.amount,
    required this.unit,
    required this.requiredBy,
    this.description,
    this.status = 'pending',
    this.acceptedBy,
    this.acceptedAt,
    this.createdAt,
  });

  final String id;
  final String ngoId;
  final String ngoName;
  final int amount;
  final String unit; // 'meals', 'kg', 'plates'
  final DateTime requiredBy;
  final String? description;
  final String status; // 'pending', 'accepted', 'fulfilled', 'ignored'
  final String? acceptedBy;
  final DateTime? acceptedAt;
  final DateTime? createdAt;

  factory NGODemand.fromJson(Map<String, dynamic> json) {
    return NGODemand(
      id: json['id'] as String,
      ngoId: json['ngoId'] is String 
          ? json['ngoId'] as String
          : (json['ngoId'] as Map<String, dynamic>?)?['_id'] as String? ?? '',
      ngoName: json['ngoName'] as String,
      amount: (json['amount'] as num).toInt(),
      unit: json['unit'] as String,
      requiredBy: DateTime.parse(json['requiredBy'] as String),
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      acceptedBy: json['acceptedBy'] as String?,
      acceptedAt: json['acceptedAt'] != null 
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'amount': amount,
      'unit': unit,
      'requiredBy': requiredBy.toIso8601String(),
      'description': description,
      'status': status,
      'acceptedBy': acceptedBy,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get formattedAmount => '$amount $unit';
  
  String get formattedDate {
    final now = DateTime.now();
    final difference = requiredBy.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} left';
    } else {
      return 'Overdue';
    }
  }
}

