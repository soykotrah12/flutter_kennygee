class RestaurantMenuItemModel {
  const RestaurantMenuItemModel({
    required this.name,
    required this.price,
    required this.image,
    this.isLiked = false,
  });

  final String name;
  final double price;
  final String image;
  final bool isLiked;
}

class RestaurantModel {
  const RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.address,
    required this.openingHours,
    this.isLiked = false,
    this.subtitle = 'Italian Restaurant',
    this.type = 'restaurant',
    this.popularDishes = const <String>[],
    this.menuItems = const <RestaurantMenuItemModel>[],
  });

  final String id;
  final String name;
  final String subtitle;
  final String image;
  final double rating;
  final int reviewsCount;
  final String distance;
  final String address;
  final String openingHours;
  final bool isLiked;
  final String type;
  final List<String> popularDishes;
  final List<RestaurantMenuItemModel> menuItems;
}
