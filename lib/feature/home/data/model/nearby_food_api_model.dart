class NearbyFoodApiModel {
  const NearbyFoodApiModel({
    required this.menuId,
    required this.dishName,
    required this.description,
    required this.images,
    required this.category,
    required this.price,
    required this.specialOffer,
    required this.offerText,
    required this.shop,
    required this.createdAt,
    required this.ratingValue,
    required this.averageRating,
    required this.hasAverageRating,
    required this.reviewCount,
    required this.hasReviewCount,
    required this.reviewsLength,
  });

  factory NearbyFoodApiModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> reviews = _asList(json['reviews']);

    return NearbyFoodApiModel(
      menuId: (json['menuId'] ?? json['_id'] ?? '').toString(),
      dishName: (json['dishName'] ?? json['name'] ?? 'Food').toString(),
      description: (json['description'] ?? '').toString(),
      images: _asList(json['images']).map(_asMap).toList(),
      category: (json['category'] ?? '').toString(),
      price: _toDouble(json['price']),
      specialOffer: json['specialOffer'] == true,
      offerText: (json['offerText'] ?? '').toString(),
      shop: _asMap(json['shop']),
      createdAt: (json['createdAt'] ?? '').toString(),
      ratingValue: _toDouble(json['rating']),
      averageRating: _toDouble(json['averageRating']),
      hasAverageRating: json.containsKey('averageRating'),
      reviewCount: _toInt(json['reviewCount']),
      hasReviewCount: json.containsKey('reviewCount'),
      reviewsLength: reviews.length,
    );
  }

  final String menuId;
  final String dishName;
  final String description;
  final List<Map<String, dynamic>> images;
  final String category;
  final double price;
  final bool specialOffer;
  final String offerText;
  final Map<String, dynamic> shop;
  final String createdAt;
  final double ratingValue;
  final double averageRating;
  final bool hasAverageRating;
  final int reviewCount;
  final bool hasReviewCount;
  final int reviewsLength;

  String get imageUrl {
    if (images.isNotEmpty) {
      final String url = (images.first['url'] ?? '').toString();
      if (url.isNotEmpty) return url;
    }

    final Map<String, dynamic> image = _asMap(shop['image']);
    return (image['url'] ?? '').toString();
  }

  List<String> get imageUrls {
    final List<String> urls = images
        .map((image) => (image['url'] ?? '').toString())
        .where((url) => url.trim().isNotEmpty)
        .toList();

    if (urls.isNotEmpty) {
      return urls;
    }

    final String fallback = imageUrl;
    if (fallback.trim().isEmpty) {
      return const <String>[];
    }
    return <String>[fallback];
  }

  String get restaurantName =>
      (shop['restaurantName'] ?? 'Restaurant').toString();

  String get shopId => (shop['shopId'] ?? shop['_id'] ?? '').toString();

  String get address => (shop['address'] ?? '').toString();

  double get rating {
    if (hasAverageRating) return averageRating;
    if (ratingValue > 0) return ratingValue;
    return _toDouble(shop['rating']);
  }

  int get reviewsCount {
    if (hasReviewCount) return reviewCount;
    if (reviewsLength > 0) return reviewsLength;

    final dynamic shopReviewCount = shop['reviewCount'] ?? shop['reviewsCount'];
    return _toInt(shopReviewCount);
  }

  String get distance => (shop['distance'] ?? '').toString();

  String get openingHours {
    final Map<String, dynamic> operatingToday = _asMap(shop['operatingToday']);
    if (operatingToday['closed'] == true) {
      return 'Closed today';
    }

    final String open = (operatingToday['open'] ?? '').toString();
    final String close = (operatingToday['close'] ?? '').toString();

    if (open.isNotEmpty && close.isNotEmpty) {
      return '$open - $close';
    }
    if (open.isNotEmpty) return 'Open: $open';
    if (close.isNotEmpty) return 'Until $close';
    return 'Time unavailable';
  }
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

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return <dynamic>[];
}
