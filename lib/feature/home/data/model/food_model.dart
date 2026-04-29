class FoodModel {
  const FoodModel({
    required this.id,
    this.shopId = '',
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.restaurantName,
    required this.distance,
    required this.address,
    required this.openingHours,
    this.images = const <String>[],
    this.isLiked = false,
    this.specialOffer = false,
    this.offerText = '',
    this.category = '',
  });

  final String id;
  final String shopId;
  final String name;
  final String image;
  final double price;
  final double rating;
  final int reviewsCount;
  final String description;
  final String restaurantName;
  final String distance;
  final String address;
  final String openingHours;
  final List<String> images;
  final bool isLiked;
  final bool specialOffer;
  final String offerText;
  final String category;

  /// Convert FoodModel to UpdateMenuResponseModel for the update screen
  /// This creates a mock response based on available data
  dynamic toUpdateMenuResponseModel() {
    final List<dynamic> imagesList = images.asMap().entries.map((entry) {
      return {'publicId': '', 'url': entry.value, 'id': ''};
    }).toList();

    return {
      'menuId': id,
      'shopId': shopId,
      'dishName': name,
      'description': description,
      'category': category,
      'basePrice': price,
      'specialOffer': specialOffer,
      'offerText': offerText,
      'images': imagesList,
      'createdAt': '',
      'updatedAt': '',
    };
  }
}
