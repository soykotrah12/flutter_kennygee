import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/bookmark_shop_model.dart';

class ProfileBookmarkRepository {
  ProfileBookmarkRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<BookmarkShopModel>> fetchMyBookmarks() {
    return _apiClient.get<List<BookmarkShopModel>>(
      ApiConstants.bookmark.fetchMyBookmarks,
      fromJsonT: (json) {
        final List<dynamic> rawItems = _extractBookmarkList(json);
        return rawItems
            .map(_normalizeBookmarkItem)
            .map(BookmarkShopModel.fromJson)
            .where((item) => item.id.trim().isNotEmpty)
            .toList();
      },
    );
  }
}

List<dynamic> _extractBookmarkList(dynamic json) {
  if (json is List) return json;

  final Map<String, dynamic> payload = _asMap(json);
  if (payload.isEmpty) return <dynamic>[];

  const List<String> directListKeys = <String>[
    'bookmarks',
    'bookmarkShops',
    'shopItems',
    'shops',
    'items',
  ];

  for (final String key in directListKeys) {
    final dynamic candidate = payload[key];
    if (candidate is List) return candidate;
  }

  final dynamic dataField = payload['data'];
  if (dataField is List) return dataField;

  final Map<String, dynamic> nestedData = _asMap(dataField);
  for (final String key in directListKeys) {
    final dynamic candidate = nestedData[key];
    if (candidate is List) return candidate;
  }

  return <dynamic>[];
}

Map<String, dynamic> _normalizeBookmarkItem(dynamic rawItem) {
  final Map<String, dynamic> item = _asMap(rawItem);

  Map<String, dynamic> nestedShop = _asMap(item['shop']);
  if (nestedShop.isEmpty) {
    nestedShop = _asMap(item['restaurant']);
  }
  if (nestedShop.isEmpty && item['shopId'] is Map) {
    nestedShop = _asMap(item['shopId']);
  }
  if (nestedShop.isEmpty && item['data'] is Map) {
    nestedShop = _asMap(item['data']);
  }

  if (nestedShop.isEmpty) {
    return item;
  }

  return <String, dynamic>{...item, ...nestedShop};
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
