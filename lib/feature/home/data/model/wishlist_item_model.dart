enum WishlistItemType { restaurant, food }

extension WishlistItemTypeApiX on WishlistItemType {
  String get apiType {
    switch (this) {
      case WishlistItemType.restaurant:
        return 'shop';
      case WishlistItemType.food:
        return 'menu';
    }
  }
}

class WishlistItemModel {
  const WishlistItemModel({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.distance,
    required this.openingHours,
    this.isLiked = true,
  });

  final String id;
  final WishlistItemType type;
  final String name;
  final String description;
  final String image;
  final double rating;
  final String distance;
  final String openingHours;
  final bool isLiked;

  factory WishlistItemModel.fromShopJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: _readString(json['id']),
      type: WishlistItemType.restaurant,
      name: _resolveName(json),
      description: _readString(json['description']),
      image: _resolveImageUrl(json['image']),
      rating: _toDouble(json['rating']),
      distance: _resolveDistance(json['distance']),
      openingHours: _resolveOperatingHours(json['operatingToday']),
    );
  }

  factory WishlistItemModel.fromMenuJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: _readString(json['id']),
      type: WishlistItemType.food,
      name: _resolveName(json),
      description: _readString(json['description']),
      image: _resolveImageUrl(json['image']),
      rating: _toDouble(json['rating']),
      distance: _resolveDistance(json['distance']),
      openingHours: _resolveOperatingHours(json['operatingToday']),
    );
  }

  static String _resolveName(Map<String, dynamic> json) {
    final String restaurantName = _readString(json['restaurantName']);
    if (restaurantName.isNotEmpty) return restaurantName;

    final String name = _readString(json['name']);
    if (name.isNotEmpty) return name;

    final String title = _readString(json['title']);
    if (title.isNotEmpty) return title;

    return 'Unnamed';
  }

  static String _resolveImageUrl(dynamic imageValue) {
    final Map<String, dynamic> image = _asMap(imageValue);
    final String imageUrl = _readString(image['url']);
    return imageUrl;
  }

  static String _resolveDistance(dynamic distanceValue) {
    final String distance = _readString(distanceValue);
    if (distance.isNotEmpty) return distance;
    return 'N/A';
  }

  static String _resolveOperatingHours(dynamic operatingTodayValue) {
    final Map<String, dynamic> operatingToday = _asMap(operatingTodayValue);
    final bool isClosed = operatingToday['closed'] == true;
    if (isClosed) return 'Closed today';

    final String open = _readString(operatingToday['open']);
    final String close = _readString(operatingToday['close']);

    if (open.isNotEmpty && close.isNotEmpty) {
      return '$open - $close';
    }
    if (open.isNotEmpty) {
      return 'Open: $open';
    }
    if (close.isNotEmpty) {
      return 'Until $close';
    }

    return 'Time unavailable';
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

String _readString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}
