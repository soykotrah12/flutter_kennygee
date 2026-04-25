class EventApiModel {
  const EventApiModel({
    required this.eventId,
    required this.shopName,
    required this.shopAddress,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.entryFee,
    required this.interested,
    required this.isGoing,
  });

  factory EventApiModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> image = _asMap(json['image']);

    return EventApiModel(
      eventId: (json['eventId'] ?? '').toString(),
      shopName: (json['shopName'] ?? '').toString(),
      shopAddress: (json['shopAddress'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (image['url'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      entryFee: _toDouble(json['entryFee']),
      interested: _toInt(json['interested']),
      isGoing: json['isGoing'] == true,
    );
  }

  final String eventId;
  final String shopName;
  final String shopAddress;
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final String time;
  final double entryFee;
  final int interested;
  final bool isGoing;
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
