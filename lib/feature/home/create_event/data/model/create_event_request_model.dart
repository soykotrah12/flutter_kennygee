class CreateEventRequestModel {
  const CreateEventRequestModel({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.entryFee,
    this.imagePath,
  });

  final String title;
  final String description;
  final DateTime date;
  final String time;
  final double entryFee;
  final String? imagePath;

  Map<String, dynamic> toPayload() {
    final bool isWholeFee = entryFee % 1 == 0;

    return <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'date': DateTime.utc(date.year, date.month, date.day).toIso8601String(),
      'time': time.trim(),
      'entryFee': isWholeFee ? entryFee.toInt() : entryFee,
    };
  }
}
