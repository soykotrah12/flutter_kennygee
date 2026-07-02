import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/google_nearby_restaurant_model.dart';

class GoogleNearbyRestaurantRepository {
  GoogleNearbyRestaurantRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<GoogleNearbyRestaurantsResponseModel> fetchRestaurants({
    required double lat,
    required double lng,
    required int radius,
    String search = '',
  }) {
    final Map<String, dynamic> query = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };
    final String trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      query['search'] = trimmedSearch;
    }

    if (kDebugMode) {
      final Uri uri = Uri.parse(ApiConstants.shop.fetchGoogleNearbyRestaurants)
          .replace(
            queryParameters: query.map((key, value) {
              return MapEntry(key, value.toString());
            }),
          );
      debugPrint('GOOGLE NEARBY RESTAURANTS URL => $uri');
    }

    return _apiClient.get<GoogleNearbyRestaurantsResponseModel>(
      ApiConstants.shop.fetchGoogleNearbyRestaurants,
      queryParameters: query,
      includeAuth: false,
      redirectOnUnauthorized: false,
      fromJsonT: (json) {
        final GoogleNearbyRestaurantsResponseModel response =
            GoogleNearbyRestaurantsResponseModel.fromJson(_asMap(json));
        if (kDebugMode) {
          debugPrint(
            'GOOGLE NEARBY RESTAURANTS COUNT => '
            '${response.restaurants.length}',
          );
        }
        return response;
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
