import 'food_model.dart';
import 'restaurant_model.dart';

class RecommendedShopMenuResponseModel {
  const RecommendedShopMenuResponseModel({
    required this.shops,
    required this.menus,
  });

  final List<RestaurantModel> shops;
  final List<FoodModel> menus;
}
