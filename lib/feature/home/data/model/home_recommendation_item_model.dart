import 'restaurant_model.dart';

class HomeRecommendationItemModel {
  const HomeRecommendationItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.image,
    required this.rating,
    required this.distance,
    required this.openingHours,
    this.restaurant,
  });

  final String id;
  final String type;
  final String title;
  final String image;
  final double rating;
  final String distance;
  final String openingHours;
  final RestaurantModel? restaurant;
}
