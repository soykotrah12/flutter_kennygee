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
  });

  factory NearbyFoodApiModel.fromJson(Map<String, dynamic> json) {
    return NearbyFoodApiModel(
      menuId: (json['menuId'] ?? '').toString(),
      dishName: (json['dishName'] ?? 'Food').toString(),
      description: (json['description'] ?? '').toString(),
      images: _asList(json['images']).map(_asMap).toList(),
      category: (json['category'] ?? '').toString(),
      price: _toDouble(json['price']),
      specialOffer: json['specialOffer'] == true,
      offerText: (json['offerText'] ?? '').toString(),
      shop: _asMap(json['shop']),
      createdAt: (json['createdAt'] ?? '').toString(),
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

  String get imageUrl {
    if (images.isNotEmpty) {
      final String url = (images.first['url'] ?? '').toString();
      if (url.isNotEmpty) return url;
    }

    final Map<String, dynamic> image = _asMap(shop['image']);
    return (image['url'] ?? '').toString();
  }

  String get restaurantName =>
      (shop['restaurantName'] ?? 'Restaurant').toString();

  String get address => (shop['address'] ?? '').toString();

  double get rating => _toDouble(shop['rating']);

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
