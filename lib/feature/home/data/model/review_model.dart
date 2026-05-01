class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerRole,
    required this.reviewerImage,
    required this.rating,
    required this.reviewText,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> reviewer = _asMap(
      json['reviewer'] ?? json['reviewerId'] ?? json['user'] ?? json['userId'],
    );
    final Map<String, dynamic> reviewerImageMap = _asMap(json['reviewerImage']);
    final Map<String, dynamic> profileImage = _asMap(
      reviewer['profileImage'] ?? reviewer['avatar'],
    );
    final String directReviewerName =
        (json['reviewerName'] ?? json['name'] ?? '').toString().trim();

    return ReviewModel(
      id: (json['reviewId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      reviewerName: directReviewerName.isNotEmpty
          ? directReviewerName
          : _resolveReviewerName(reviewer),
      reviewerRole: (reviewer['role'] ?? 'User').toString(),
      reviewerImage: (reviewerImageMap['url'] ?? profileImage['url'] ?? '')
          .toString(),
      rating: _toDouble(json['rating']),
      reviewText: (json['reviewText'] ?? '').toString(),
      likes: _toInt(json['likes']),
      comments: _toInt(json['comments']),
      isLiked: _toBool(
        json['isLiked'] ??
            json['liked'] ??
            json['isLikedByCurrentUser'] ??
            json['likedByCurrentUser'],
      ),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  final String id;
  final String reviewerName;
  final String reviewerRole;
  final String reviewerImage;
  final double rating;
  final String reviewText;
  final int likes;
  final int comments;
  final bool isLiked;
  final String createdAt;

  ReviewModel copyWith({
    String? id,
    String? reviewerName,
    String? reviewerRole,
    String? reviewerImage,
    double? rating,
    String? reviewText,
    int? likes,
    int? comments,
    bool? isLiked,
    String? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerRole: reviewerRole ?? this.reviewerRole,
      reviewerImage: reviewerImage ?? this.reviewerImage,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ReviewFetchResultModel {
  const ReviewFetchResultModel({
    required this.type,
    required this.totalReviews,
    required this.averageRating,
    required this.reviews,
  });

  factory ReviewFetchResultModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> result = _asMap(
      json['result'] is Map ? json['result'] : json,
    );
    final List<dynamic> rawReviews = _asList(result['reviews']);
    final int mappedTotalReviews = _toInt(
      result['totalReviews'] ??
          result['reviewCount'] ??
          result['reviewsCount'] ??
          rawReviews.length,
    );
    final double mappedAverageRating = _toDouble(
      result['averageRating'] ?? result['rating'],
    );

    return ReviewFetchResultModel(
      type: (result['type'] ?? json['type'] ?? '').toString(),
      totalReviews: mappedTotalReviews,
      averageRating: mappedAverageRating,
      reviews: rawReviews
          .map((item) => ReviewModel.fromJson(_asMap(item)))
          .toList(),
    );
  }

  final String type;
  final int totalReviews;
  final double averageRating;
  final List<ReviewModel> reviews;
}

String _resolveReviewerName(Map<String, dynamic> reviewer) {
  final String direct = (reviewer['name'] ?? '').toString().trim();
  if (direct.isNotEmpty) return direct;

  final String first = (reviewer['firstName'] ?? '').toString().trim();
  final String last = (reviewer['lastName'] ?? '').toString().trim();
  final String merged = '$first $last'.trim();
  if (merged.isNotEmpty) return merged;

  return 'Anonymous';
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
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String raw = (value ?? '').toString().trim().toLowerCase();
  return raw == 'true' || raw == '1' || raw == 'yes';
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is List) return List<dynamic>.from(value);
  return <dynamic>[];
}
