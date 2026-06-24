class BookmarkShopModel {
  const BookmarkShopModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.distance,
    required this.subtitle,
  });

  factory BookmarkShopModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);
    final List<dynamic> images = _asList(json['images']);

    String firstImageFromList = '';
    if (images.isNotEmpty) {
      final dynamic first = images.first;
      if (first is String) {
        firstImageFromList = first;
      } else {
        firstImageFromList =
            (_asMap(first)['url'] ?? _asMap(first)['imageUrl'] ?? '')
                .toString();
      }
    }

    final String id = _firstNonEmpty(<String>[
      (json['shopId'] ?? '').toString(),
      (json['_id'] ?? '').toString(),
      (json['id'] ?? '').toString(),
    ]);

    return BookmarkShopModel(
      id: id,
      name: _firstNonEmpty(<String>[
        (json['restaurantName'] ?? '').toString(),
        (json['name'] ?? '').toString(),
      ]),
      image: _firstNonEmpty(<String>[
        (image['url'] ?? '').toString(),
        (image['imageUrl'] ?? '').toString(),
        (json['imageUrl'] ?? '').toString(),
        (json['image'] is String ? json['image'] : '').toString(),
        firstImageFromList,
      ]),
      rating: _toDouble(json['averageRating'] ?? json['rating']),
      reviewsCount: _toInt(
        json['totalReviews'] ?? json['reviewCount'] ?? json['reviewsCount'],
      ),
      address: _firstNonEmpty(<String>[
        (json['address'] ?? '').toString(),
        (_asMap(json['location'])['address'] ?? '').toString(),
      ]),
      distance: _firstNonEmpty(<String>[(json['distance'] ?? '').toString()]),
      subtitle: _firstNonEmpty(<String>[
        (json['subtitle'] ?? '').toString(),
        (json['description'] ?? '').toString(),
      ]),
    );
  }

  final String id;
  final String name;
  final String image;
  final double rating;
  final int reviewsCount;
  final String address;
  final String distance;
  final String subtitle;
}

String _firstNonEmpty(List<String> values) {
  for (final String value in values) {
    final String candidate = value.trim();
    if (candidate.isNotEmpty && candidate.toLowerCase() != 'null') {
      return candidate;
    }
  }
  return '';
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return <dynamic>[];
}
