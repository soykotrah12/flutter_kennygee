import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/owner_analytics_model.dart';

class OwnerAnalyticsRepository {
  OwnerAnalyticsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<OwnerAnalyticsModel> fetchOwnerAnalytics() {
    return _apiClient.get<OwnerAnalyticsModel>(
      ApiConstants.analytics.fetchRestaurantOwnerAnalytics,
      fromJsonT: (json) => OwnerAnalyticsModel.fromJson(_asMap(json)),
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
