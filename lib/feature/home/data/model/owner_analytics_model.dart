class OwnerAnalyticsTrendPoint {
  const OwnerAnalyticsTrendPoint({required this.date, required this.value});

  factory OwnerAnalyticsTrendPoint.fromJson(Map<String, dynamic> json) {
    return OwnerAnalyticsTrendPoint(
      date: (json['date'] ?? '').toString(),
      value: _toDouble(json['value']),
    );
  }

  final String date;
  final double value;
}

class MostSearchFoodModel {
  const MostSearchFoodModel({
    required this.menuId,
    required this.title,
    required this.subtitle,
    required this.demandGrowth,
    required this.totalReviews,
    required this.averageRating,
  });

  factory MostSearchFoodModel.fromJson(Map<String, dynamic> json) {
    return MostSearchFoodModel(
      menuId: (json['menuId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      demandGrowth: _toDouble(json['demandGrowth']),
      totalReviews: _toInt(json['totalReviews']),
      averageRating: _toDouble(json['averageRating']),
    );
  }

  final String menuId;
  final String title;
  final String subtitle;
  final double demandGrowth;
  final int totalReviews;
  final double averageRating;
}

class OwnerAnalyticsModel {
  const OwnerAnalyticsModel({
    required this.shopId,
    required this.shopName,
    required this.shopImageUrl,
    required this.profileViews,
    required this.profileViewsLabel,
    required this.profileViewsChangePercent,
    required this.searchAppearances,
    required this.searchAppearancesLabel,
    required this.menuViews,
    required this.saves,
    required this.currentRating,
    required this.ratingSubtitle,
    required this.ratingTrend,
    required this.mostSearchFoods,
  });

  factory OwnerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> shop = _asMap(json['shop']);
    final Map<String, dynamic> shopImage = _asMap(shop['image']);

    final Map<String, dynamic> overview = _asMap(json['performanceOverview']);
    final Map<String, dynamic> realTime = _asMap(
      overview['realTimeVisibility'],
    );
    final Map<String, dynamic> profileViews = _asMap(realTime['profileViews']);
    final Map<String, dynamic> searchAppearances = _asMap(
      realTime['searchAppearances'],
    );

    final Map<String, dynamic> engagement = _asMap(overview['engagementDepth']);
    final Map<String, dynamic> menuViews = _asMap(engagement['menuViews']);
    final Map<String, dynamic> saves = _asMap(engagement['saves']);

    final Map<String, dynamic> rating = _asMap(overview['ratingConsistency']);

    final List<dynamic> rawTrend = _asList(rating['trend']);
    final List<dynamic> rawFoods = _asList(overview['mostSearchFoods']);

    return OwnerAnalyticsModel(
      shopId: (shop['_id'] ?? '').toString(),
      shopName: (shop['restaurantName'] ?? '').toString(),
      shopImageUrl: (shopImage['url'] ?? '').toString(),
      profileViews: _toInt(profileViews['value']),
      profileViewsLabel: (profileViews['label'] ?? '').toString(),
      profileViewsChangePercent: _toDouble(profileViews['changePercent']),
      searchAppearances: _toInt(searchAppearances['value']),
      searchAppearancesLabel: (searchAppearances['label'] ?? '').toString(),
      menuViews: _toInt(menuViews['value']),
      saves: _toInt(saves['value']),
      currentRating: _toDouble(rating['currentRating']),
      ratingSubtitle: (rating['subtitle'] ?? '').toString(),
      ratingTrend: rawTrend
          .map((item) => OwnerAnalyticsTrendPoint.fromJson(_asMap(item)))
          .toList(),
      mostSearchFoods: rawFoods
          .map((item) => MostSearchFoodModel.fromJson(_asMap(item)))
          .toList(),
    );
  }

  final String shopId;
  final String shopName;
  final String shopImageUrl;

  final int profileViews;
  final String profileViewsLabel;
  final double profileViewsChangePercent;

  final int searchAppearances;
  final String searchAppearancesLabel;

  final int menuViews;
  final int saves;

  final double currentRating;
  final String ratingSubtitle;
  final List<OwnerAnalyticsTrendPoint> ratingTrend;

  final List<MostSearchFoodModel> mostSearchFoods;
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

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
