class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.restaurantName,
    required this.distance,
    required this.address,
    required this.openingHours,
    this.images = const <String>[],
    this.isLiked = false,
  });

  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final int reviewsCount;
  final String description;
  final String restaurantName;
  final String distance;
  final String address;
  final String openingHours;
  final List<String> images;
  final bool isLiked;
}
