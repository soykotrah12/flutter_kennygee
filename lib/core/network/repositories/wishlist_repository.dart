import '../api_client.dart';
import '../constants/api_constants.dart';
import '../network_result.dart';

class WishlistRepository {
  WishlistRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<Map<String, dynamic>> toggleWishlist({
    required String type,
    required String itemId,
  }) {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.wishlist.toggleWishlist,
      data: <String, dynamic>{'type': type, 'itemId': itemId},
      fromJsonT: (json) => _asMap(json),
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
