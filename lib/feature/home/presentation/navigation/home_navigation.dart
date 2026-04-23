import 'package:get/get.dart';

import '../../data/model/restaurant_model.dart';
import '../screens/restaurant_details_screen.dart';

class HomeNavigation {
  HomeNavigation._();

  static void openRestaurantDetails(RestaurantModel restaurant) {
    Get.to(() => RestaurantDetailsScreen(restaurant: restaurant));
  }
}
