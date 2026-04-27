class UpdateMenuResponseModel {
  const UpdateMenuResponseModel({
    required this.menuId,
    required this.shopId,
    required this.dishName,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.specialOffer,
    required this.offerText,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UpdateMenuResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawImages = json['images'] is List
        ? json['images'] as List<dynamic>
        : <dynamic>[];

    return UpdateMenuResponseModel(
      menuId: (json['_id'] ?? '').toString(),
      shopId: (json['shopId'] ?? '').toString(),
      dishName: (json['dishName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      basePrice: _toDouble(json['basePrice']),
      specialOffer: (json['specialOffer'] ?? false) as bool,
      offerText: (json['offerText'] ?? '').toString(),
      images: rawImages
          .map((item) => UpdateMenuImageModel.fromJson(_asMap(item)))
          .toList(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  /// Create from FoodModel (typically from shop menus list)
  factory UpdateMenuResponseModel.fromFoodModel(
    dynamic foodModel, {
    String shopId = '',
  }) {
    // Handle both FoodModel directly and Map representations
    if (foodModel is Map<String, dynamic>) {
      return UpdateMenuResponseModel.fromJson(foodModel);
    }

    final String menuId = foodModel.id ?? '';
    final String dishName = foodModel.name ?? '';
    final String description = foodModel.description ?? '';
    final String category = foodModel.category ?? '';
    final double basePrice = (foodModel.price ?? 0).toDouble();
    final bool specialOffer = foodModel.specialOffer ?? false;
    final String offerText = foodModel.offerText ?? '';
    final List<String> imageUrls = foodModel.images ?? <String>[];

    final List<UpdateMenuImageModel> images = imageUrls
        .map(
          (url) => UpdateMenuImageModel(
            publicId: '',
            url: url,
            id: '',
          ),
        )
        .toList();

    return UpdateMenuResponseModel(
      menuId: menuId,
      shopId: shopId,
      dishName: dishName,
      description: description,
      category: category,
      basePrice: basePrice,
      specialOffer: specialOffer,
      offerText: offerText,
      images: images,
      createdAt: '',
      updatedAt: '',
    );
  }

  final String menuId;
  final String shopId;
  final String dishName;
  final String description;
  final String category;
  final double basePrice;
  final bool specialOffer;
  final String offerText;
  final List<UpdateMenuImageModel> images;
  final String createdAt;
  final String updatedAt;
}

class UpdateMenuImageModel {
  const UpdateMenuImageModel({
    required this.publicId,
    required this.url,
    required this.id,
  });

  factory UpdateMenuImageModel.fromJson(Map<String, dynamic> json) {
    return UpdateMenuImageModel(
      publicId: (json['public_id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      id: (json['_id'] ?? '').toString(),
    );
  }

  final String publicId;
  final String url;
  final String id;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
