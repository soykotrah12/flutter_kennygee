class NearbyShopApiModel {
  const NearbyShopApiModel({
    required this.shopId,
    required this.restaurantName,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.openTime,
    required this.closeTime,
    required this.isClosedToday,
  });

  factory NearbyShopApiModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);
    final Map<String, dynamic> operatingToday = _asMap(json['operatingToday']);
    final Map<String, dynamic> operatingHours = _asMap(json['operatingHours']);
    final _OperatingSlot slot = _resolveOperatingSlot(
      operatingToday: operatingToday,
      operatingHours: operatingHours,
    );
    final Map<String, dynamic> location = _asMap(json['location']);
    final String rawDistance = (json['distance'] ?? '').toString();

    return NearbyShopApiModel(
      shopId: (json['shopId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? 'Restaurant').toString(),
      imageUrl: (image['url'] ?? '').toString(),
      address: (json['address'] ?? location['address'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount'] ?? json['reviewsCount']),
      distance: rawDistance.toLowerCase() == 'null' ? '' : rawDistance,
      openTime: slot.open,
      closeTime: slot.close,
      isClosedToday: slot.closed,
    );
  }

  final String shopId;
  final String restaurantName;
  final String imageUrl;
  final String address;
  final double rating;
  final int reviewCount;
  final String distance;
  final String openTime;
  final String closeTime;
  final bool isClosedToday;
}

class _OperatingSlot {
  const _OperatingSlot({
    required this.open,
    required this.close,
    required this.closed,
  });

  final String open;
  final String close;
  final bool closed;
}

_OperatingSlot _resolveOperatingSlot({
  required Map<String, dynamic> operatingToday,
  required Map<String, dynamic> operatingHours,
}) {
  final bool hasTodayOpen = (operatingToday['open'] ?? '')
      .toString()
      .trim()
      .isNotEmpty;
  final bool hasTodayClose = (operatingToday['close'] ?? '')
      .toString()
      .trim()
      .isNotEmpty;
  final bool hasTodayClosedFlag = operatingToday['closed'] == true;

  if (hasTodayOpen || hasTodayClose || hasTodayClosedFlag) {
    return _OperatingSlot(
      open: (operatingToday['open'] ?? '').toString(),
      close: (operatingToday['close'] ?? '').toString(),
      closed: operatingToday['closed'] == true,
    );
  }

  final String dayKey = _weekdayKey(DateTime.now().weekday);
  final Map<String, dynamic> daySlot = _asMap(operatingHours[dayKey]);
  if (daySlot.isNotEmpty) {
    return _OperatingSlot(
      open: (daySlot['open'] ?? '').toString(),
      close: (daySlot['close'] ?? '').toString(),
      closed: daySlot['closed'] == true,
    );
  }

  return const _OperatingSlot(open: '', close: '', closed: false);
}

String _weekdayKey(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'monday';
    case DateTime.tuesday:
      return 'tuesday';
    case DateTime.wednesday:
      return 'wednesday';
    case DateTime.thursday:
      return 'thursday';
    case DateTime.friday:
      return 'friday';
    case DateTime.saturday:
      return 'saturday';
    default:
      return 'sunday';
  }
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
