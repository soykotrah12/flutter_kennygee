import 'package:get/get.dart';

import '../../data/model/food_model.dart';
import '../../data/model/restaurant_model.dart';
import '../screens/single_food_screen.dart';
import '../screens/restaurant_details_screen.dart';

class HomeNavigation {
  HomeNavigation._();

  static void openRestaurantDetails(RestaurantModel restaurant) {
    Get.to(() => RestaurantDetailsScreen(restaurant: restaurant));
  }

  static void openFoodDetails(FoodModel food) {
    Get.to(() => SingleFoodScreen(food: food));
  }
}
