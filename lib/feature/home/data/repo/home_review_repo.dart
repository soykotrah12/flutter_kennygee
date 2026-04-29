import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/review_model.dart';

class HomeReviewRepository {
  HomeReviewRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<ReviewModel>> fetchReviews({required String id}) {
    return _apiClient.get<List<ReviewModel>>(
      ApiConstants.review.fetchReviews(id),
      fromJsonT: (json) {
        final List<dynamic> raw = _extractList(json);
        return raw.map((item) => ReviewModel.fromJson(_asMap(item))).toList();
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

  List<dynamic> _extractList(dynamic json) {
    if (json is List) return json;

    final Map<String, dynamic> map = _asMap(json);
    if (map['reviews'] is List) {
      return map['reviews'] as List<dynamic>;
    }

    if (map['items'] is List) {
      return map['items'] as List<dynamic>;
    }

    return <dynamic>[];
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
