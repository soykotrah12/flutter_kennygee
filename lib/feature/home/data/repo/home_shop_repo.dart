import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/food_model.dart';
import '../model/nearby_shop_api_model.dart';
import '../model/recommended_shop_menu_response_model.dart';
import '../model/restaurant_model.dart';
import '../model/shop_details_api_model.dart';

class HomeShopRepository {
  HomeShopRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<RestaurantModel>> fetchNearbyShops({
    required double lat,
    required double lng,
    required int radius,
  }) {
    return _apiClient.get<List<RestaurantModel>>(
      ApiConstants.shop.fetchNearbyShops,
      queryParameters: <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': radius,
      },
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => NearbyShopApiModel.fromJson(_asMap(item)))
            .map(_toRestaurantModel)
            .toList();
      },
    );
  }

  NetworkResult<RecommendedShopMenuResponseModel> fetchRecommendedShops({
    required double lat,
    required double lng,
    required int radius,
  }) {
    return _apiClient.get<RecommendedShopMenuResponseModel>(
      ApiConstants.shop.fetchRecommendedShops,
      queryParameters: <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': radius,
      },
      fromJsonT: (json) {
        final Map<String, dynamic> root = _asMap(json);

        // New API shape: { shops: [], menus: [] }
        // Backward fallback: direct list of shops.
        final List<dynamic> rawShops = root['shops'] is List
            ? root['shops'] as List<dynamic>
            : json is List
            ? json
            : <dynamic>[];
        final dynamic menusPayload = root['menus'] ?? root['menues'];
        final List<dynamic> rawMenus = menusPayload is List
            ? menusPayload
            : <dynamic>[];

        final List<RestaurantModel> shops = rawShops
            .map((item) => NearbyShopApiModel.fromJson(_asMap(item)))
            .map(_toRestaurantModel)
            .toList();

        final Map<String, RestaurantModel> shopMap = <String, RestaurantModel>{
          for (final RestaurantModel shop in shops) shop.id: shop,
        };

        final List<FoodModel> menus = rawMenus
            .map((item) => _toRecommendedFoodModel(_asMap(item), shopMap))
            .toList();

        return RecommendedShopMenuResponseModel(shops: shops, menus: menus);
      },
    );
  }

  NetworkResult<RestaurantModel> fetchShopDetails({required String shopId}) {
    return _apiClient.get<RestaurantModel>(
      ApiConstants.shop.fetchShopDetails(shopId),
      fromJsonT: (json) {
        final ShopDetailsApiModel raw = ShopDetailsApiModel.fromJson(
          _asMap(json),
        );
        return _toRestaurantDetailsModel(raw);
      },
    );
  }

  RestaurantModel _toRestaurantModel(NearbyShopApiModel shop) {
    final String opening = _resolveOpeningHours(shop);

    return RestaurantModel(
      id: shop.shopId,
      name: shop.restaurantName,
      subtitle: '',
      image: shop.imageUrl,
      rating: shop.rating,
      reviewsCount: shop.reviewCount,
      distance: shop.distance,
      address: shop.address,
      openingHours: opening,
      isLiked: false,
      popularDishes: const <String>[],
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
    );
  }

  FoodModel _toRecommendedFoodModel(
    Map<String, dynamic> json,
    Map<String, RestaurantModel> shopMap,
  ) {
    final Map<String, dynamic> rawShop = _asMap(json['shop']);
    final String shopId =
        (json['shopId'] ?? rawShop['shopId'] ?? rawShop['_id'] ?? '')
            .toString();
    final RestaurantModel? shop =
        shopMap[shopId] ??
        (rawShop.isNotEmpty
            ? _toRestaurantModel(NearbyShopApiModel.fromJson(rawShop))
            : null);

    final List<dynamic> rawImages = json['images'] is List
        ? json['images'] as List<dynamic>
        : <dynamic>[];
    final List<String> imageUrls = rawImages
        .map((item) => _asMap(item))
        .map((img) => (img['url'] ?? '').toString())
        .where((url) => url.trim().isNotEmpty)
        .toList();
    final String singleImageUrl = (_asMap(json['image'])['url'] ?? '')
        .toString();
    final List<String> resolvedImageUrls = imageUrls.isNotEmpty
        ? imageUrls
        : singleImageUrl.trim().isNotEmpty
        ? <String>[singleImageUrl]
        : const <String>[];

    final String fallbackShopImage = shop?.image.trim().isNotEmpty == true
        ? shop!.image
        : '';

    final String image = resolvedImageUrls.isNotEmpty
        ? resolvedImageUrls.first
        : fallbackShopImage;

    final String openingHours = shop?.openingHours.trim().isNotEmpty == true
        ? shop!.openingHours
        : 'Hours not available';

    return FoodModel(
      id: (json['menuId'] ?? json['_id'] ?? '').toString(),
      shopId: shopId,
      name: (json['dishName'] ?? json['name'] ?? '').toString(),
      image: image,
      price: _toDouble(json['price'] ?? json['basePrice']),
      rating: _toDouble(json['averageRating'] ?? json['rating']),
      reviewsCount: _toInt(
        json['totalReviews'] ??
            json['reviewCount'] ??
            (json['reviews'] is List ? (json['reviews'] as List).length : 0),
      ),
      description: (json['description'] ?? json['category'] ?? '').toString(),
      restaurantName: shop?.name ?? '',
      distance: shop?.distance ?? '',
      address: shop?.address ?? '',
      openingHours: openingHours,
      images: resolvedImageUrls.isNotEmpty
          ? resolvedImageUrls
          : image.trim().isNotEmpty
          ? <String>[image]
          : const <String>[],
      isLiked: false,
      specialOffer: json['specialOffer'] == true,
      offerText: (json['offerText'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
    );
  }

  RestaurantModel _toRestaurantDetailsModel(ShopDetailsApiModel shop) {
    final String opening = _resolveOpeningHoursFromRaw(
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
    );

    final List<RestaurantMenuCategoryModel> menuCategories = shop
        .foodsByCategory
        .map(
          (category) => RestaurantMenuCategoryModel(
            name: category.category,
            items: category.items
                .map(
                  (dish) => RestaurantMenuItemModel(
                    id: dish.menuId,
                    name: dish.dishName,
                    price: dish.price,
                    image: shop.imageUrl,
                    isLiked: false,
                  ),
                )
                .toList(),
          ),
        )
        .where((category) => category.items.isNotEmpty)
        .toList();
    final List<RestaurantMenuItemModel> menuItems = menuCategories
        .expand((category) => category.items)
        .toList();
    final List<RestaurantMenuItemModel> fallbackMenuItems = shop.popularDishes
        .map(
          (dish) => RestaurantMenuItemModel(
            id: dish.menuId,
            name: dish.dishName,
            price: dish.price,
            image: shop.imageUrl,
            isLiked: false,
          ),
        )
        .toList();
    final List<RestaurantMenuItemModel> resolvedMenuItems = menuItems.isNotEmpty
        ? menuItems
        : fallbackMenuItems;
    final List<String> categoryNames = menuCategories
        .map((category) => category.name)
        .where((name) => name.trim().isNotEmpty)
        .toList();

    return RestaurantModel(
      id: shop.shopId,
      name: shop.restaurantName,
      subtitle: '',
      image: shop.imageUrl,
      rating: shop.rating,
      reviewsCount: shop.reviewsCount,
      distance: shop.distance,
      address: shop.address,
      openingHours: opening,
      isLiked: false,
      popularDishes: categoryNames.isNotEmpty
          ? categoryNames
          : shop.popularDishes.map((dish) => dish.dishName).toList(),
      menuItems: resolvedMenuItems,
      menuCategories: menuCategories,
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
      operatingHours: shop.operatingHours
          .map(
            (item) => RestaurantOperatingHoursEntryModel(
              day: item.dayLabel,
              open: item.open,
              close: item.close,
              isClosed: item.closed,
            ),
          )
          .toList(),
    );
  }

  String _resolveOpeningHours(NearbyShopApiModel shop) {
    return _resolveOpeningHoursFromRaw(
      openTime: shop.openTime,
      closeTime: shop.closeTime,
      isClosedToday: shop.isClosedToday,
    );
  }

  String _resolveOpeningHoursFromRaw({
    required String openTime,
    required String closeTime,
    required bool isClosedToday,
  }) {
    if (isClosedToday) return 'Closed today';

    final bool hasOpen = openTime.trim().isNotEmpty;
    final bool hasClose = closeTime.trim().isNotEmpty;

    if (hasOpen && hasClose) {
      return '$openTime - $closeTime';
    }

    if (hasOpen) return 'Open: $openTime';
    if (hasClose) return 'Until $closeTime';
    return 'Hours not available';
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
