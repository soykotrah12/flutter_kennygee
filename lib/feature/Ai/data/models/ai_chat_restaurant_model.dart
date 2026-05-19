class AiChatRestaurantModel {
  const AiChatRestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    this.rating,
    this.distance,
    this.priceLabel,
    this.openingHours,
    this.cuisine,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final double? rating;
  final String? distance;
  final String? priceLabel;
  final String? openingHours;
  final String? cuisine;

  factory AiChatRestaurantModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);
    final Map<String, dynamic> location = _asMap(json['location']);
    final Map<String, dynamic> operatingHours = _asMap(json['operatingHours']);

    final String description = _asString(json['description']);

    return AiChatRestaurantModel(
      id: _asString(json['_id']).isNotEmpty
          ? _asString(json['_id'])
          : _asString(json['id']),
      name: _asString(json['restaurantName']).isNotEmpty
          ? _asString(json['restaurantName'])
          : 'Restaurant',
      description: description,
      imageUrl: _asString(image['url']),
      address: _asString(location['address']),
      rating:
          _asDouble(json['rating']) ??
          _asDouble(json['avgRating']) ??
          _asDouble(json['averageRating']),
      distance: _asString(json['distance']).isNotEmpty
          ? _asString(json['distance'])
          : null,
      priceLabel: _asString(json['priceRange']).isNotEmpty
          ? _asString(json['priceRange'])
          : (_asString(json['price']).isNotEmpty
                ? _asString(json['price'])
                : null),
      openingHours: _resolveOpeningHours(operatingHours),
      cuisine: _resolveCuisine(description, json),
    );
  }

  static String _resolveCuisine(String description, Map<String, dynamic> json) {
    final String cuisine = _asString(json['cuisine']);
    if (cuisine.isNotEmpty) return cuisine;

    final String category = _asString(json['category']);
    if (category.isNotEmpty) return category;

    final List<String> parts = description.split(' ');
    final String firstWord = parts.isEmpty ? '' : parts.first;
    return firstWord;
  }

  static String? _resolveOpeningHours(Map<String, dynamic> operatingHours) {
    if (operatingHours.isEmpty) return null;

    for (final dynamic value in operatingHours.values) {
      final Map<String, dynamic> day = _asMap(value);
      final bool isClosed = day['closed'] == true;
      final String open = _asString(day['open']);
      final String close = _asString(day['close']);

      if (!isClosed && open.isNotEmpty && close.isNotEmpty) {
        return open;
      }
    }

    return null;
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

String _asString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  return value.toString().trim();
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
