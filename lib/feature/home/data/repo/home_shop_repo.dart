import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/nearby_shop_api_model.dart';
import '../model/restaurant_model.dart';

class HomeShopRepository {
  HomeShopRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<RestaurantModel>> fetchNearbyShops({
    required double lat,
    required double lng,
    required int radius,
  }) {
    return _apiClient.get<List<RestaurantModel>>(
      ApiConstants.shop.fetchNearbyShops,
      queryParameters: <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': radius,
      },
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => NearbyShopApiModel.fromJson(_asMap(item)))
            .map(_toRestaurantModel)
            .toList();
      },
    );
  }

  RestaurantModel _toRestaurantModel(NearbyShopApiModel shop) {
    final String opening = _resolveOpeningHours(shop);

    return RestaurantModel(
      id: shop.shopId,
      name: shop.restaurantName,
      subtitle: 'Restaurant',
      image: shop.imageUrl,
      rating: shop.rating,
      reviewsCount: 0,
      distance: shop.distance.isNotEmpty ? shop.distance : 'N/A',
      address: shop.address,
      openingHours: opening,
      isLiked: true,
      popularDishes: const <String>['Pasta', 'Burger', 'Cheesecake'],
    );
  }

  String _resolveOpeningHours(NearbyShopApiModel shop) {
    if (shop.isClosedToday) return 'Closed today';

    final bool hasOpen = shop.openTime.trim().isNotEmpty;
    final bool hasClose = shop.closeTime.trim().isNotEmpty;

    if (hasOpen && hasClose) {
      return '${shop.openTime} - ${shop.closeTime}';
    }

    return '11:00 AM - 10:00 PM';
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
