class CreateShopRequestModel {
  const CreateShopRequestModel({
    required this.userId,
    required this.restaurantName,
    required this.description,
    required this.imagePath,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.eventDate,
    required this.openTime,
    required this.closeTime,
  });

  final String userId;
  final String restaurantName;
  final String description;
  final String imagePath;
  final String address;
  final double longitude;
  final double latitude;
  final DateTime eventDate;
  final String openTime;
  final String closeTime;

  String get selectedDayKey {
    switch (eventDate.weekday) {
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
      case DateTime.sunday:
        return 'sunday';
    }
    return 'monday';
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'userId': userId.trim(),
      'restaurantName': restaurantName.trim(),
      'description': description.trim(),
      'location': <String, dynamic>{
        'type': 'Point',
        'coordinates': <double>[longitude, latitude],
        'address': address.trim(),
      },
      'operatingHours': _buildOperatingHours(),
    };
  }

  Map<String, dynamic> _buildOperatingHours() {
    const List<String> days = <String>[
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    final Map<String, dynamic> hours = <String, dynamic>{};

    for (final String day in days) {
      final bool isSelected = day == selectedDayKey;
      hours[day] = <String, dynamic>{
        'open': isSelected ? openTime.trim() : '',
        'close': isSelected ? closeTime.trim() : '',
        'closed': false,
      };
    }

    return hours;
  }
}
