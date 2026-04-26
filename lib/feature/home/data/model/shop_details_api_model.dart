class ShopPopularDishApiModel {
  const ShopPopularDishApiModel({
    required this.menuId,
    required this.dishName,
    required this.price,
  });

  factory ShopPopularDishApiModel.fromJson(Map<String, dynamic> json) {
    return ShopPopularDishApiModel(
      menuId: (json['menuId'] ?? '').toString(),
      dishName: (json['dishName'] ?? '').toString(),
      price: _toDouble(json['price']),
    );
  }

  final String menuId;
  final String dishName;
  final double price;
}

class ShopDetailsApiModel {
  const ShopDetailsApiModel({
    required this.shopId,
    required this.restaurantName,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.openTime,
    required this.closeTime,
    required this.isClosedToday,
    required this.popularDishes,
  });

  factory ShopDetailsApiModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);
    final Map<String, dynamic> operatingToday = _asMap(json['operatingToday']);
    final List<dynamic> rawDishes = json['popularDishes'] is List
        ? json['popularDishes'] as List<dynamic>
        : <dynamic>[];
    final List<dynamic> rawReviews = json['reviews'] is List
        ? json['reviews'] as List<dynamic>
        : <dynamic>[];
    final String rawDistance = (json['distance'] ?? '').toString();

    final int mappedReviewCount = _toInt(
      json['reviewCount'] ?? json['reviewsCount'],
    );

    return ShopDetailsApiModel(
      shopId: (json['shopId'] ?? json['_id'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? 'Restaurant').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (image['url'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      rating: _toDouble(json['rating'] ?? json['averageRating']),
      reviewsCount: mappedReviewCount > 0 ? mappedReviewCount : rawReviews.length,
      distance: rawDistance.toLowerCase() == 'null' ? '' : rawDistance,
      openTime: (operatingToday['open'] ?? '').toString(),
      closeTime: (operatingToday['close'] ?? '').toString(),
      isClosedToday: operatingToday['closed'] == true,
      popularDishes: rawDishes
          .map((item) => ShopPopularDishApiModel.fromJson(_asMap(item)))
          .toList(),
    );
  }

  final String shopId;
  final String restaurantName;
  final String description;
  final String imageUrl;
  final String address;
  final double rating;
  final int reviewsCount;
  final String distance;
  final String openTime;
  final String closeTime;
  final bool isClosedToday;
  final List<ShopPopularDishApiModel> popularDishes;
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
