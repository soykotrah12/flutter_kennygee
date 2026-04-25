import 'package:get/get.dart';

import '../../data/model/event_model.dart';
import '../../data/model/food_model.dart';
import '../../data/model/restaurant_model.dart';
import '../screens/event_details_screen.dart';
import '../screens/events_screen.dart';
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

  static void openEvents() {
    Get.to(() => const EventsScreen());
  }

  static void openEventDetails(EventModel event) {
    Get.to(() => EventDetailsScreen(event: event));
  }
}
