class CreateEventImageModel {
  const CreateEventImageModel({required this.publicId, required this.url});

  factory CreateEventImageModel.fromJson(Map<String, dynamic> json) {
    return CreateEventImageModel(
      publicId: (json['public_id'] ?? json['publicId'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
    );
  }

  final String publicId;
  final String url;
}

class CreateEventResponseModel {
  const CreateEventResponseModel({
    required this.eventId,
    required this.shopId,
    required this.shopName,
    required this.shopAddress,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.time,
    required this.entryFee,
    required this.interested,
    required this.platformServiceFee,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateEventResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateEventResponseModel(
      eventId: (json['eventId'] ?? json['_id'] ?? '').toString(),
      shopId: (json['shopId'] ?? '').toString(),
      shopName: (json['shopName'] ?? '').toString(),
      shopAddress: (json['shopAddress'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      image: CreateEventImageModel.fromJson(_asMap(json['image'])),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      entryFee: _toDouble(json['entryFee']),
      interested: _toInt(json['interested']),
      platformServiceFee: _toDouble(json['platformServiceFee']),
      total: _toDouble(json['total']),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  final String eventId;
  final String shopId;
  final String shopName;
  final String shopAddress;
  final String title;
  final String description;
  final CreateEventImageModel image;
  final String date;
  final String time;
  final double entryFee;
  final int interested;
  final double platformServiceFee;
  final double total;
  final String createdAt;
  final String updatedAt;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
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
