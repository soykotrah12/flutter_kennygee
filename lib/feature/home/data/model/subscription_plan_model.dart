class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.planName,
    required this.price,
    required this.duration,
    required this.features,
    required this.badge,
    required this.isPopular,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawFeatures = json['features'] is List
        ? json['features'] as List<dynamic>
        : <dynamic>[];

    return SubscriptionPlanModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      planName: (json['planName'] ?? '').toString(),
      price: _toDouble(json['price']),
      duration: (json['duration'] ?? 'month').toString(),
      features: rawFeatures.map((item) => item.toString()).toList(),
      badge: (json['badge'] ?? '').toString(),
      isPopular: json['isPopular'] == true,
      isActive: json['isActive'] == true,
    );
  }

  final String id;
  final String planName;
  final double price;
  final String duration;
  final List<String> features;
  final String badge;
  final bool isPopular;
  final bool isActive;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
