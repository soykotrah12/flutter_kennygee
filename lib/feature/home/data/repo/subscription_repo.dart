import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/subscription_plan_model.dart';

class SubscriptionRepository {
  SubscriptionRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<SubscriptionPlanModel>> fetchPlans() {
    return _apiClient.get<List<SubscriptionPlanModel>>(
      ApiConstants.subscription.getSubscriptions,
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => SubscriptionPlanModel.fromJson(_asMap(item)))
            .toList();
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
