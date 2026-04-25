import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/food_model.dart';
import '../model/nearby_food_api_model.dart';

class HomeFoodRepository {
  HomeFoodRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<FoodModel>> fetchNearbyFoods({
    required double lat,
    required double lng,
  }) {
    return _apiClient.get<List<FoodModel>>(
      ApiConstants.baseUrl + '/menu/nearby',
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

  FoodModel _toFoodModel(NearbyFoodApiModel food) {
    return FoodModel(
      id: food.menuId,
      name: food.dishName,
      image: food.imageUrl,
      price: food.price,
      rating: food.rating,
      reviewsCount: 0,
      description: food.description,
      restaurantName: food.restaurantName,
      distance: food.distance.isNotEmpty ? food.distance : 'N/A',
      address: food.address,
      openingHours: food.openingHours,
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
