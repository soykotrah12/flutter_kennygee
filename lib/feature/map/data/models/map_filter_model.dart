class MapFilterModel {
  const MapFilterModel({
    required this.distanceKm,
    required this.minimumRating,
    required this.priceRange,
    required this.openNowOnly,
  });

  final double distanceKm;
  final double minimumRating;
  final String priceRange;
  final bool openNowOnly;

  factory MapFilterModel.defaults() {
    return const MapFilterModel(
      distanceKm: 12,
      minimumRating: 4,
      priceRange: '',
      openNowOnly: false,
    );
  }

  MapFilterModel copyWith({
    double? distanceKm,
    double? minimumRating,
    String? priceRange,
    bool? openNowOnly,
  }) {
    return MapFilterModel(
      distanceKm: distanceKm ?? this.distanceKm,
      minimumRating: minimumRating ?? this.minimumRating,
      priceRange: priceRange ?? this.priceRange,
      openNowOnly: openNowOnly ?? this.openNowOnly,
    );
  }
}
