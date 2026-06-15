import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/stripe_connect_status_model.dart';
import '../model/stripe_onboarding_response_model.dart';

class StripeConnectRepository {
  StripeConnectRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<StripeConnectStatusModel> fetchStatus({
    CancelToken? cancelToken,
  }) {
    return _apiClient.get<StripeConnectStatusModel>(
      ApiConstants.stripeConnect.fetchStatus,
      cancelToken: cancelToken,
      fromJsonT: (json) => StripeConnectStatusModel.fromJson(_asMap(json)),
    );
  }

  NetworkResult<StripeOnboardingResponseModel> createOnboardingLink() {
    return _apiClient.post<StripeOnboardingResponseModel>(
      ApiConstants.stripeConnect.createOnboardingLink,
      fromJsonT: (json) => StripeOnboardingResponseModel.fromJson(_asMap(json)),
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
