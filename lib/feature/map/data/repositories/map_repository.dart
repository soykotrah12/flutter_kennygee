import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../models/map_restaurant_model.dart';

class MapRepository {
  MapRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MapRestaurantModel>> fetchRestaurants({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final result = await _apiClient.get<List<MapRestaurantModel>>(
      ApiConstants.shop.fetchNearbyShops,
      queryParameters: <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': (radiusKm * 1000).round(),
      },
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => _toRestaurant(_asMap(item)))
            .where((item) => item.hasValidCoordinates)
            .toList();
      },
    );

    return result.fold(
      (_) => <MapRestaurantModel>[],
      (success) => success.data,
    );
  }

  Future<Map<String, List<String>>> fetchShopSearchKeywords() async {
    final result = await _apiClient.get<Map<String, List<String>>>(
      ApiConstants.shop.fetchRecommendedShops,
      fromJsonT: (json) {
        final Map<String, dynamic> root = _asMap(json);
        final List<dynamic> menus = root['menus'] is List
            ? root['menus'] as List<dynamic>
            : <dynamic>[];

        final Map<String, Set<String>> temp = <String, Set<String>>{};

        for (final dynamic item in menus) {
          final Map<String, dynamic> menu = _asMap(item);
          final String shopId = (menu['shopId'] ?? menu['shop'] ?? '')
              .toString()
              .trim();
          if (shopId.isEmpty) continue;

          final Set<String> keywords = temp.putIfAbsent(
            shopId,
            () => <String>{},
          );

          final String dish = (menu['dishName'] ?? '').toString().trim();
          final String category = (menu['category'] ?? '').toString().trim();
          final String desc = (menu['description'] ?? '').toString().trim();

          if (dish.isNotEmpty) keywords.add(dish);
          if (category.isNotEmpty) keywords.add(category);
          if (desc.isNotEmpty) keywords.add(desc);
        }

        return temp.map(
          (key, value) =>
              MapEntry(key, value.where((e) => e.isNotEmpty).toList()),
        );
      },
    );

    return result.fold(
      (_) => <String, List<String>>{},
      (success) => success.data,
    );
  }

  MapRestaurantModel _toRestaurant(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);
    final Map<String, dynamic> location = _asMap(json['location']);
    final Map<String, dynamic> operatingToday = _asMap(json['operatingToday']);
    final Map<String, dynamic> operatingHours = _asMap(json['operatingHours']);
    final _OperatingSlot slot = _resolveOperatingSlot(
      operatingToday: operatingToday,
      operatingHours: operatingHours,
    );

    final List<double> coordinates = _toCoordinates(location['coordinates']);
    final String shopId = (json['shopId'] ?? json['_id'] ?? json['id'] ?? '')
        .toString();

    return MapRestaurantModel(
      shopId: shopId,
      restaurantName: (json['restaurantName'] ?? '').toString(),
      imageUrl: (image['url'] ?? '').toString(),
      address: (location['address'] ?? json['address'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      reviewsCount: _toInt(json['reviewCount'] ?? json['reviewsCount']),
      distanceLabel: _resolveDistanceLabel(json['distance']),
      latitude: coordinates.length > 1 ? coordinates[1] : 0,
      longitude: coordinates.isNotEmpty ? coordinates[0] : 0,
      isClosedToday: slot.closed,
      openTime: slot.open,
      closeTime: slot.close,
    );
  }
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

List<double> _toCoordinates(dynamic value) {
  final List<dynamic> raw = value is List ? value : <dynamic>[];
  return raw.map(_toDouble).toList();
}

String _resolveDistanceLabel(dynamic value) {
  final String raw = (value ?? '').toString();
  if (raw.trim().isEmpty || raw.toLowerCase() == 'null') return '';
  return raw;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
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
