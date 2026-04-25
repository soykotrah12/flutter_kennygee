import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/wishlist_item_model.dart';

class HomeWishlistRepository {
  HomeWishlistRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<WishlistItemModel>> fetchMyWishlist({
    required String type,
    required double lat,
    required double lng,
    required int radius,
  }) {
    return _apiClient.get<List<WishlistItemModel>>(
      ApiConstants.wishlist.fetchMyWishlist,
      queryParameters: <String, dynamic>{
        'type': type,
        'lat': lat,
        'lng': lng,
        'radius': radius,
      },
      fromJsonT: (json) {
        final Map<String, dynamic> payload = _asMap(json);
        final List<WishlistItemModel> shopItems = _asList(
          payload['shopItems'],
        ).map(_asMap).map(WishlistItemModel.fromShopJson).toList();
        final List<WishlistItemModel> menuItems = _asList(
          payload['menuItems'],
        ).map(_asMap).map(WishlistItemModel.fromMenuJson).toList();

        switch (type) {
          case 'restaurant':
            return shopItems;
          case 'food':
            return menuItems;
          default:
            return <WishlistItemModel>[...shopItems, ...menuItems];
        }
      },
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return <dynamic>[];
}
