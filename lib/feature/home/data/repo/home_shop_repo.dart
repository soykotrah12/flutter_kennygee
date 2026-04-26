import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/shop_details_api_model.dart';
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

  NetworkResult<List<RestaurantModel>> fetchRecommendedShops({
    required double lat,
    required double lng,
    required int radius,
  }) {
    return _apiClient.get<List<RestaurantModel>>(
      ApiConstants.shop.fetchRecommendedShops,
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

  NetworkResult<RestaurantModel> fetchShopDetails({
    required String shopId,
  }) {
    return _apiClient.get<RestaurantModel>(
      ApiConstants.shop.fetchShopDetails(shopId),
      fromJsonT: (json) {
        final ShopDetailsApiModel raw = ShopDetailsApiModel.fromJson(
          _asMap(json),
        );
        return _toRestaurantDetailsModel(raw);
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
      reviewsCount: shop.reviewCount,
      distance: shop.distance.isNotEmpty ? shop.distance : 'N/A',
      address: shop.address,
      openingHours: opening,
      isLiked: false,
      popularDishes: const <String>['Pasta', 'Burger', 'Cheesecake'],
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
    );
  }

  RestaurantModel _toRestaurantDetailsModel(ShopDetailsApiModel shop) {
    final String opening = _resolveOpeningHoursFromRaw(
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
    );

    final List<RestaurantMenuItemModel> menuItems = shop.popularDishes
        .map(
          (dish) => RestaurantMenuItemModel(
            id: dish.menuId,
            name: dish.dishName,
            price: dish.price,
            image: shop.imageUrl,
            isLiked: false,
          ),
        )
        .toList();

    return RestaurantModel(
      id: shop.shopId,
      name: shop.restaurantName,
      subtitle: 'Restaurant',
      image: shop.imageUrl,
      rating: shop.rating,
      reviewsCount: shop.reviewsCount,
      distance: shop.distance.isNotEmpty ? shop.distance : 'N/A',
      address: shop.address,
      openingHours: opening,
      isLiked: false,
      popularDishes: shop.popularDishes.map((dish) => dish.dishName).toList(),
      menuItems: menuItems,
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
    );
  }

  String _resolveOpeningHours(NearbyShopApiModel shop) {
    return _resolveOpeningHoursFromRaw(
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
    );
  }

  String _resolveOpeningHoursFromRaw({
    required String openTime,
    required String closeTime,
    required bool isClosedToday,
  }) {
    if (isClosedToday) return 'Closed today';

    final bool hasOpen = openTime.trim().isNotEmpty;
    final bool hasClose = closeTime.trim().isNotEmpty;

    if (hasOpen && hasClose) {
      return '$openTime - $closeTime';
    }

    if (hasOpen) return 'Open: $openTime';
    if (hasClose) return 'Until $closeTime';
    return 'Time unavailable';
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
