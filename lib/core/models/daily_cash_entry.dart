class DailyCashEntry {
  const DailyCashEntry({
    required this.id,
    required this.currency,
    required this.receipt,
    required this.payment,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String currency;
  final String receipt;
  final String payment;
  final String description;
  final DateTime createdAt;

  factory DailyCashEntry.fromJson(Map<String, dynamic> json) {
    final createdValue = json['createdAt'] ?? json['created_at'];
    return DailyCashEntry(
      id: '${json['id']}',
      currency: (json['currency'] ?? '') as String,
      receipt: (json['receipt'] ?? '') as String,
      payment: (json['payment'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      createdAt: createdValue == null
          ? DateTime.now()
          : DateTime.tryParse('$createdValue') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'receipt': receipt,
      'payment': payment,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
