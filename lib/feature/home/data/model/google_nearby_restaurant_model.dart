class GoogleNearbyRestaurantModel {
  const GoogleNearbyRestaurantModel({
    required this.googlePlaceId,
    required this.restaurantName,
    required this.rating,
    required this.totalRatings,
    required this.distance,
    required this.address,
    required this.imageUrl,
    required this.isOpenNow,
    required this.latitude,
    required this.longitude,
    required this.source,
  });

  factory GoogleNearbyRestaurantModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> location = _asMap(json['location']);
    final Map<String, dynamic> image = _asMap(json['image']);
    final List<double> coordinates = _toCoordinates(location['coordinates']);

    return GoogleNearbyRestaurantModel(
      googlePlaceId: (json['googlePlaceId'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      totalRatings: _toInt(json['totalRatings']),
      distance: _toDouble(json['distance']),
      address: (location['address'] ?? json['address'] ?? '').toString(),
      imageUrl: (image['url'] ?? '').toString(),
      isOpenNow: json['isOpenNow'] is bool ? json['isOpenNow'] as bool : null,
      latitude: coordinates.length > 1 ? coordinates[1] : 0,
      longitude: coordinates.isNotEmpty ? coordinates[0] : 0,
      source: (json['source'] ?? '').toString(),
    );
  }

  final String googlePlaceId;
  final String restaurantName;
  final double rating;
  final int totalRatings;
  final double distance;
  final String address;
  final String imageUrl;
  final bool? isOpenNow;
  final double latitude;
  final double longitude;
  final String source;

  bool get hasValidCoordinates => latitude != 0 || longitude != 0;

  String get title => restaurantName.trim().isEmpty
      ? 'Google Restaurant'
      : restaurantName.trim();

  String get distanceLabel {
    if (distance <= 0) return 'Distance unavailable';
    return '${distance.toStringAsFixed(distance >= 10 ? 0 : 2)} km';
  }

  String get openStatusLabel {
    if (isOpenNow == true) return 'Open now';
    if (isOpenNow == false) return 'Closed';
    return 'Hours not available';
  }

  String get reviewsLabel {
    if (totalRatings <= 0) return 'No reviews yet';
    if (totalRatings >= 1000) {
      final double compact = totalRatings / 1000;
      return '${compact.toStringAsFixed(1)}k reviews';
    }
    return '$totalRatings reviews';
  }
}

class GoogleNearbyRestaurantsResponseModel {
  const GoogleNearbyRestaurantsResponseModel({
    required this.radius,
    required this.search,
    required this.totalRestaurants,
    required this.restaurants,
  });

  factory GoogleNearbyRestaurantsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> raw = json['restaurants'] is List
        ? json['restaurants'] as List<dynamic>
        : <dynamic>[];

    return GoogleNearbyRestaurantsResponseModel(
      radius: _toInt(json['radius']),
      search: json['search']?.toString(),
      totalRestaurants: _toInt(json['totalRestaurants']),
      restaurants: raw
          .map((item) => GoogleNearbyRestaurantModel.fromJson(_asMap(item)))
          .toList(),
    );
  }

  final int radius;
  final String? search;
  final int totalRestaurants;
  final List<GoogleNearbyRestaurantModel> restaurants;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

List<double> _toCoordinates(dynamic value) {
  final List<dynamic> raw = value is List ? value : <dynamic>[];
  return raw.map(_toDouble).toList();
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
