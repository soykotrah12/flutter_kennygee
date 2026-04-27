class ShopMenuImageApiModel {
  const ShopMenuImageApiModel({required this.publicId, required this.url});

  factory ShopMenuImageApiModel.fromJson(Map<String, dynamic> json) {
    return ShopMenuImageApiModel(
      publicId: (json['public_id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
    );
  }

  final String publicId;
  final String url;
}

class ShopMenuItemApiModel {
  const ShopMenuItemApiModel({
    required this.menuId,
    required this.dishName,
    required this.images,
    required this.price,
    required this.category,
  });

  factory ShopMenuItemApiModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawImages = json['images'] is List
        ? json['images'] as List<dynamic>
        : <dynamic>[];

    return ShopMenuItemApiModel(
      menuId: (json['menuId'] ?? json['_id'] ?? '').toString(),
      dishName: (json['dishName'] ?? '').toString(),
      images: rawImages
          .map((item) => ShopMenuImageApiModel.fromJson(_asMap(item)))
          .toList(),
      price: _toDouble(json['price']),
      category: (json['category'] ?? '').toString(),
    );
  }

  final String menuId;
  final String dishName;
  final List<ShopMenuImageApiModel> images;
  final double price;
  final String category;
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
