class UpdateMenuRequestModel {
  const UpdateMenuRequestModel({
    required this.dishName,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.specialOffer,
    required this.offerText,
    this.imagePath,
  });

  final String dishName;
  final String description;
  final String category;
  final double basePrice;
  final bool specialOffer;
  final String offerText;
  final String? imagePath;

  String get priceString => basePrice.toString();
}
