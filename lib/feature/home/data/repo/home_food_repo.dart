import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/food_model.dart';
import '../model/nearby_food_api_model.dart';
import '../model/shop_menu_item_api_model.dart';

class HomeFoodRepository {
  HomeFoodRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<FoodModel>> fetchNearbyFoods({
    required double lat,
    required double lng,
  }) {
    return _apiClient.get<List<FoodModel>>(
      ApiConstants.menu.fetchNearbyMenus,
      queryParameters: <String, dynamic>{'lat': lat, 'lng': lng},
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => NearbyFoodApiModel.fromJson(_asMap(item)))
            .map(_toFoodModel)
            .toList();
      },
    );
  }

  NetworkResult<FoodModel> fetchMenuDetails({
    required String menuId,
    required double lat,
    required double lng,
  }) {
    return _apiClient.get<FoodModel>(
      ApiConstants.menu.fetchMenuDetails(menuId),
      queryParameters: <String, dynamic>{'lat': lat, 'lng': lng},
      fromJsonT: (json) {
        final NearbyFoodApiModel raw = NearbyFoodApiModel.fromJson(
          _asMap(json),
        );
        return _toFoodModel(raw);
      },
    );
  }

  NetworkResult<List<FoodModel>> fetchShopMenus({required String shopId}) {
    return _apiClient.get<List<FoodModel>>(
      ApiConstants.menu.fetchShopMenus(shopId),
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => ShopMenuItemApiModel.fromJson(_asMap(item)))
            .map(_toShopFoodModel)
            .toList();
      },
    );
  }

  FoodModel _toFoodModel(NearbyFoodApiModel food) {
    return FoodModel(
      id: food.menuId,
      name: food.dishName,
      image: food.imageUrl,
      price: food.price,
      rating: food.rating,
      reviewsCount: food.reviewsCount,
      description: food.description,
      restaurantName: food.restaurantName,
      distance: food.distance.isNotEmpty ? food.distance : 'N/A',
      address: food.address,
      openingHours: food.openingHours,
      images: food.imageUrls,
      isLiked: false,
    );
  }

  FoodModel _toShopFoodModel(ShopMenuItemApiModel food) {
    final String firstImageUrl = food.images.isNotEmpty
        ? food.images.first.url
        : '';

    return FoodModel(
      id: food.menuId,
      name: food.dishName,
      image: firstImageUrl,
      price: food.price,
      rating: 0,
      reviewsCount: 0,
      description: food.category,
      restaurantName: '',
      distance: '',
      address: '',
      openingHours: '',
      images: food.images.map((image) => image.url).toList(),
      isLiked: false,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
