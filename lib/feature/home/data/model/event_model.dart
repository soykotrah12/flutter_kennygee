class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.image,
    required this.date,
    required this.time,
    required this.fee,
    required this.location,
    required this.detailsTitle,
    required this.detailsDescription,
    this.actionLabel = 'I am Going',
    this.isGoing = false,
  });

  final String id;
  final String title;
  final String image;
  final String date;
  final String time;
  final String fee;
  final String location;
  final String detailsTitle;
  final String detailsDescription;
  final String actionLabel;
  final bool isGoing;
}
