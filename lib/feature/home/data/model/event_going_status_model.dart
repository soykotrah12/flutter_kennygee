class EventGoingStatusModel {
  const EventGoingStatusModel({
    required this.eventId,
    required this.interested,
    required this.isGoing,
  });

  factory EventGoingStatusModel.fromJson(Map<String, dynamic> json) {
    return EventGoingStatusModel(
      eventId: (json['eventId'] ?? '').toString(),
      interested: _toInt(json['interested']),
      isGoing: json['isGoing'] == true,
    );
  }

  final String eventId;
  final int interested;
  final bool isGoing;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
