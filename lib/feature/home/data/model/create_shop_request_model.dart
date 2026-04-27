class CreateShopOperatingDayRequestModel {
  const CreateShopOperatingDayRequestModel({
    required this.open,
    required this.close,
    required this.closed,
  });

  final String open;
  final String close;
  final bool closed;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'open': open.trim(),
      'close': close.trim(),
      'closed': closed,
    };
  }
}

class CreateShopRequestModel {
  const CreateShopRequestModel({
    required this.userId,
    required this.restaurantName,
    required this.description,
    required this.address,
    required this.longitude,
    required this.latitude,
    this.imagePath,
    this.operatingHours,
    this.eventDate,
    this.openTime,
    this.closeTime,
  });

  final String userId;
  final String restaurantName;
  final String description;
  final String? imagePath;
  final String address;
  final double longitude;
  final double latitude;
  final Map<String, CreateShopOperatingDayRequestModel>? operatingHours;
  final DateTime? eventDate;
  final String? openTime;
  final String? closeTime;

  String get selectedDayKey {
    final DateTime sourceDate = eventDate ?? DateTime.now();

    switch (sourceDate.weekday) {
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
    if (operatingHours != null && operatingHours!.isNotEmpty) {
      return operatingHours!.map(
        (key, value) => MapEntry(key.toLowerCase(), value.toJson()),
      );
    }

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
      final String resolvedOpen = isSelected ? (openTime ?? '').trim() : '';
      final String resolvedClose = isSelected ? (closeTime ?? '').trim() : '';

      hours[day] = <String, dynamic>{
        'open': resolvedOpen,
        'close': resolvedClose,
        'closed': false,
      };
    }

    return hours;
  }
}
