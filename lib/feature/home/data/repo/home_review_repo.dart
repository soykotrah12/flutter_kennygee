import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/review_model.dart';

class HomeReviewRepository {
  HomeReviewRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<ReviewFetchResultModel> fetchReviews({
    String? shopId,
    String? menuId,
  }) {
    final Map<String, dynamic> queryParameters = <String, dynamic>{};
    if (menuId != null && menuId.trim().isNotEmpty) {
      queryParameters['menuId'] = menuId.trim();
    } else if (shopId != null && shopId.trim().isNotEmpty) {
      queryParameters['shopId'] = shopId.trim();
    }

    return _apiClient.get<ReviewFetchResultModel>(
      ApiConstants.review.fetchReviews,
      queryParameters: queryParameters,
      fromJsonT: (json) {
        return ReviewFetchResultModel.fromJson(_asMap(json));
      },
    );
  }

  NetworkResult<ReviewModel> createReview({
    String? shopId,
    String? menuId,
    required int rating,
    required String reviewText,
  }) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'rating': rating,
      'reviewText': reviewText,
    };

    if (shopId != null && shopId.trim().isNotEmpty) {
      payload['shopId'] = shopId.trim();
    }

    if (menuId != null && menuId.trim().isNotEmpty) {
      payload['menuId'] = menuId.trim();
    }

    return _apiClient.post<ReviewModel>(
      ApiConstants.review.createReview,
      data: payload,
      fromJsonT: (json) => ReviewModel.fromJson(_asMap(json)),
    );
  }

  NetworkResult<Map<String, dynamic>> toggleReviewLike({
    required String reviewId,
  }) {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.review.toggleReviewLike(reviewId),
      fromJsonT: _asMap,
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
