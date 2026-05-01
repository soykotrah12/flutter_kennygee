class ShopPopularDishApiModel {
  const ShopPopularDishApiModel({
    required this.menuId,
    required this.dishName,
    required this.price,
  });

  factory ShopPopularDishApiModel.fromJson(Map<String, dynamic> json) {
    return ShopPopularDishApiModel(
      menuId: (json['menuId'] ?? '').toString(),
      dishName: (json['dishName'] ?? '').toString(),
      price: _toDouble(json['price']),
    );
  }

  final String menuId;
  final String dishName;
  final double price;
}

class ShopFoodsCategoryApiModel {
  const ShopFoodsCategoryApiModel({
    required this.category,
    required this.items,
  });

  final String category;
  final List<ShopPopularDishApiModel> items;
}

class ShopOperatingHoursEntryApiModel {
  const ShopOperatingHoursEntryApiModel({
    required this.dayKey,
    required this.dayLabel,
    required this.open,
    required this.close,
    required this.closed,
  });

  final String dayKey;
  final String dayLabel;
  final String open;
  final String close;
  final bool closed;
}

class ShopDetailsApiModel {
  const ShopDetailsApiModel({
    required this.shopId,
    required this.restaurantName,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.openTime,
    required this.closeTime,
    required this.isClosedToday,
    required this.operatingHours,
    required this.popularDishes,
    required this.foodsByCategory,
  });

  factory ShopDetailsApiModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);
    final Map<String, dynamic> operatingToday = _asMap(json['operatingToday']);
    final Map<String, dynamic> operatingHours = _asMap(json['operatingHours']);
    final _OperatingSlot slot = _resolveOperatingSlot(
      operatingToday: operatingToday,
      operatingHours: operatingHours,
    );
    final List<ShopOperatingHoursEntryApiModel> mappedOperatingHours =
        _mapOperatingHours(operatingHours);
    final Map<String, dynamic> location = _asMap(json['location']);
    final Map<String, dynamic> rawFoodsByCategory = _asMap(
      json['foodsByCategory'],
    );
    final List<ShopFoodsCategoryApiModel> mappedFoodsByCategory =
        rawFoodsByCategory.entries.map((entry) {
          final List<dynamic> rawItems = entry.value is List
              ? entry.value as List<dynamic>
              : <dynamic>[];

          return ShopFoodsCategoryApiModel(
            category: entry.key.toString(),
            items: rawItems
                .map((item) => ShopPopularDishApiModel.fromJson(_asMap(item)))
                .toList(),
          );
        }).toList();
    final List<ShopPopularDishApiModel> flattenedCategorizedFoods =
        mappedFoodsByCategory.expand((category) => category.items).toList();
    final List<dynamic> rawMenus = json['menus'] is List
        ? json['menus'] as List<dynamic>
        : <dynamic>[];
    final List<ShopFoodsCategoryApiModel> menuBackedCategories =
        _buildCategoriesFromMenus(rawMenus);
    final List<ShopPopularDishApiModel> flattenedMenuFoods =
        menuBackedCategories.expand((category) => category.items).toList();
    final List<dynamic> rawDishes = json['popularDishes'] is List
        ? json['popularDishes'] as List<dynamic>
        : <dynamic>[];
    final List<dynamic> rawReviews = json['reviews'] is List
        ? json['reviews'] as List<dynamic>
        : <dynamic>[];
    final String rawDistance = (json['distance'] ?? '').toString();

    final int mappedReviewCount = _toInt(
      json['reviewCount'] ?? json['reviewsCount'],
    );

    return ShopDetailsApiModel(
      shopId: (json['shopId'] ?? json['_id'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? 'Restaurant').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (image['url'] ?? '').toString(),
      address: (json['address'] ?? location['address'] ?? '').toString(),
      rating: _toDouble(json['rating'] ?? json['averageRating']),
      reviewsCount: mappedReviewCount > 0
          ? mappedReviewCount
          : rawReviews.length,
      distance: rawDistance.toLowerCase() == 'null' ? '' : rawDistance,
      openTime: slot.open,
      closeTime: slot.close,
      isClosedToday: slot.closed,
      operatingHours: mappedOperatingHours,
      popularDishes: rawDishes.isNotEmpty
          ? rawDishes
                .map((item) => ShopPopularDishApiModel.fromJson(_asMap(item)))
                .toList()
          : flattenedCategorizedFoods.isNotEmpty
          ? flattenedCategorizedFoods
          : flattenedMenuFoods,
      foodsByCategory: mappedFoodsByCategory.isNotEmpty
          ? mappedFoodsByCategory
          : menuBackedCategories,
    );
  }

  final String shopId;
  final String restaurantName;
  final String description;
  final String imageUrl;
  final String address;
  final double rating;
  final int reviewsCount;
  final String distance;
  final String openTime;
  final String closeTime;
  final bool isClosedToday;
  final List<ShopOperatingHoursEntryApiModel> operatingHours;
  final List<ShopPopularDishApiModel> popularDishes;
  final List<ShopFoodsCategoryApiModel> foodsByCategory;
}

class _OperatingSlot {
  const _OperatingSlot({
    required this.open,
    required this.close,
    required this.closed,
  });

  final String open;
  final String close;
  final bool closed;
}

_OperatingSlot _resolveOperatingSlot({
  required Map<String, dynamic> operatingToday,
  required Map<String, dynamic> operatingHours,
}) {
  final bool hasTodayOpen = (operatingToday['open'] ?? '')
      .toString()
      .trim()
      .isNotEmpty;
  final bool hasTodayClose = (operatingToday['close'] ?? '')
      .toString()
      .trim()
      .isNotEmpty;
  final bool hasTodayClosedFlag = operatingToday['closed'] == true;

  if (hasTodayOpen || hasTodayClose || hasTodayClosedFlag) {
    return _OperatingSlot(
      open: (operatingToday['open'] ?? '').toString(),
      close: (operatingToday['close'] ?? '').toString(),
      closed: operatingToday['closed'] == true,
    );
  }

  final String dayKey = _weekdayKey(DateTime.now().weekday);
  final Map<String, dynamic> daySlot = _asMap(operatingHours[dayKey]);
  if (daySlot.isNotEmpty) {
    return _OperatingSlot(
      open: (daySlot['open'] ?? '').toString(),
      close: (daySlot['close'] ?? '').toString(),
      closed: daySlot['closed'] == true,
    );
  }

  return const _OperatingSlot(open: '', close: '', closed: false);
}

String _weekdayKey(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'monday';
    case DateTime.tuesday:
      return 'tuesday';
    case DateTime.wednesday:
      return 'wednesday';
    case DateTime.thursday:
      return 'thursday';
    case DateTime.friday:
      return 'friday';
    case DateTime.saturday:
      return 'saturday';
    default:
      return 'sunday';
  }
}

List<ShopOperatingHoursEntryApiModel> _mapOperatingHours(
  Map<String, dynamic> operatingHours,
) {
  const List<String> dayKeys = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  return dayKeys.map((dayKey) {
    final Map<String, dynamic> daySlot = _asMap(operatingHours[dayKey]);
    return ShopOperatingHoursEntryApiModel(
      dayKey: dayKey,
      dayLabel: _weekdayLabel(dayKey),
      open: (daySlot['open'] ?? '').toString(),
      close: (daySlot['close'] ?? '').toString(),
      closed: daySlot['closed'] == true,
    );
  }).toList();
}

String _weekdayLabel(String dayKey) {
  final String value = dayKey.trim().toLowerCase();
  if (value.isEmpty) return '';
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

List<ShopFoodsCategoryApiModel> _buildCategoriesFromMenus(
  List<dynamic> rawMenus,
) {
  final Map<String, List<ShopPopularDishApiModel>> grouped =
      <String, List<ShopPopularDishApiModel>>{};

  for (final dynamic rawMenu in rawMenus) {
    final Map<String, dynamic> menu = _asMap(rawMenu);
    final String category = (menu['category'] ?? 'Other').toString().trim();
    final String normalizedCategory = category.isNotEmpty ? category : 'Other';

    final ShopPopularDishApiModel dish = ShopPopularDishApiModel(
      menuId: (menu['menuId'] ?? menu['_id'] ?? '').toString(),
      dishName: (menu['dishName'] ?? '').toString(),
      price: _toDouble(menu['price']),
    );

    grouped.putIfAbsent(normalizedCategory, () => <ShopPopularDishApiModel>[]);
    grouped[normalizedCategory]!.add(dish);
  }

  return grouped.entries
      .map(
        (entry) =>
            ShopFoodsCategoryApiModel(category: entry.key, items: entry.value),
      )
      .toList();
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
