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
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> reviewer = _asMap(
      json['reviewer'] ?? json['reviewerId'] ?? json['user'] ?? json['userId'],
    );
    final Map<String, dynamic> profileImage = _asMap(
      reviewer['profileImage'] ?? reviewer['avatar'],
    );

    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      reviewerName: _resolveReviewerName(reviewer),
      reviewerRole: (reviewer['role'] ?? 'User').toString(),
      reviewerImage: (profileImage['url'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      reviewText: (json['reviewText'] ?? '').toString(),
      likes: _toInt(json['likes']),
      comments: _toInt(json['comments']),
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
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
