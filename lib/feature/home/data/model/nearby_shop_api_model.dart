class NearbyShopApiModel {
  const NearbyShopApiModel({
    required this.shopId,
    required this.restaurantName,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.openTime,
    required this.closeTime,
    required this.isClosedToday,
  });

  factory NearbyShopApiModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);
    final Map<String, dynamic> operatingToday = _asMap(json['operatingToday']);
    final String rawDistance = (json['distance'] ?? '').toString();

    return NearbyShopApiModel(
      shopId: (json['shopId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? 'Restaurant').toString(),
      imageUrl: (image['url'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount'] ?? json['reviewsCount']),
      distance: rawDistance.toLowerCase() == 'null' ? '' : rawDistance,
      openTime: (operatingToday['open'] ?? '').toString(),
      closeTime: (operatingToday['close'] ?? '').toString(),
      isClosedToday: operatingToday['closed'] == true,
    );
  }

  final String shopId;
  final String restaurantName;
  final String imageUrl;
  final String address;
  final double rating;
  final int reviewCount;
  final String distance;
  final String openTime;
  final String closeTime;
  final bool isClosedToday;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
