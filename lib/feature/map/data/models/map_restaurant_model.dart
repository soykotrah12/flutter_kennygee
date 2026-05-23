class MapRestaurantModel {
  const MapRestaurantModel({
    required this.shopId,
    required this.restaurantName,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.distanceLabel,
    required this.latitude,
    required this.longitude,
    required this.isClosedToday,
    required this.openTime,
    required this.closeTime,
    this.searchKeywords = const <String>[],
  });

  final String shopId;
  final String restaurantName;
  final String imageUrl;
  final String address;
  final double rating;
  final int reviewsCount;
  final String distanceLabel;
  final double latitude;
  final double longitude;
  final bool isClosedToday;
  final String openTime;
  final String closeTime;
  final List<String> searchKeywords;

  bool get hasValidCoordinates => latitude != 0 || longitude != 0;

  String get openingLabel {
    if (isClosedToday) return 'Closed today';
    final String open = openTime.trim();
    final String close = closeTime.trim();
    if (open.isNotEmpty && close.isNotEmpty) return '$open - $close';
    if (open.isNotEmpty) return 'Open: $open';
    if (close.isNotEmpty) return 'Until $close';
    return 'Time unavailable';
  }

  String get reviewsLabel {
    if (reviewsCount <= 0) return '(0 reviews)';
    if (reviewsCount >= 1000) {
      final double compact = reviewsCount / 1000;
      return '(${compact.toStringAsFixed(1)}k reviews)';
    }
    return '($reviewsCount reviews)';
  }

  MapRestaurantModel copyWith({List<String>? searchKeywords}) {
    return MapRestaurantModel(
      shopId: shopId,
      restaurantName: restaurantName,
      imageUrl: imageUrl,
      address: address,
      rating: rating,
      reviewsCount: reviewsCount,
      distanceLabel: distanceLabel,
      latitude: latitude,
      longitude: longitude,
      isClosedToday: isClosedToday,
      openTime: openTime,
      closeTime: closeTime,
      searchKeywords: searchKeywords ?? this.searchKeywords,
    );
  }
}
