class CreateEventRequestModel {
  const CreateEventRequestModel({
    required this.shopId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.entryFee,
    required this.platformServiceFee,
    required this.total,
    this.imagePath,
  });

  final String shopId;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final double entryFee;
  final double platformServiceFee;
  final double total;
  final String? imagePath;

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'shopId': shopId.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'date': DateTime.utc(date.year, date.month, date.day).toIso8601String(),
      'time': time.trim(),
      'entryFee': _normalizeNumeric(entryFee),
      'platformServiceFee': _normalizeNumeric(platformServiceFee),
      'total': _normalizeNumeric(total),
    };
  }
}

num _normalizeNumeric(double value) {
  final bool isWhole = value % 1 == 0;
  return isWhole ? value.toInt() : value;
}
