class RestaurantMenuItemModel {
  const RestaurantMenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.isLiked = false,
  });

  final String id;
  final String name;
  final double price;
  final String image;
  final bool isLiked;
}

class RestaurantMenuCategoryModel {
  const RestaurantMenuCategoryModel({required this.name, required this.items});

  final String name;
  final List<RestaurantMenuItemModel> items;
}

class RestaurantOperatingHoursEntryModel {
  const RestaurantOperatingHoursEntryModel({
    required this.day,
    required this.open,
    required this.close,
    required this.isClosed,
  });

  final String day;
  final String open;
  final String close;
  final bool isClosed;
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
    this.subtitle = '',
    this.type = 'restaurant',
    this.popularDishes = const <String>[],
    this.menuItems = const <RestaurantMenuItemModel>[],
    this.menuCategories = const <RestaurantMenuCategoryModel>[],
    this.openTime = '',
    this.closeTime = '',
    this.isClosedToday = false,
    this.operatingHours = const <RestaurantOperatingHoursEntryModel>[],
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
  final List<RestaurantMenuCategoryModel> menuCategories;
  final String openTime;
  final String closeTime;
  final bool isClosedToday;
  final List<RestaurantOperatingHoursEntryModel> operatingHours;
}
