class CreateShopImageModel {
  const CreateShopImageModel({required this.publicId, required this.url});

  factory CreateShopImageModel.fromJson(Map<String, dynamic> json) {
    return CreateShopImageModel(
      publicId: (json['public_id'] ?? json['publicId'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
    );
  }

  final String publicId;
  final String url;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'public_id': publicId, 'url': url};
  }
}

class CreateShopLocationModel {
  const CreateShopLocationModel({
    required this.type,
    required this.coordinates,
    required this.address,
  });

  factory CreateShopLocationModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawCoordinates = json['coordinates'] is List
        ? json['coordinates'] as List<dynamic>
        : <dynamic>[];

    return CreateShopLocationModel(
      type: (json['type'] ?? '').toString(),
      coordinates: rawCoordinates.map(_toDouble).toList(),
      address: (json['address'] ?? '').toString(),
    );
  }

  final String type;
  final List<double> coordinates;
  final String address;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'coordinates': coordinates,
      'address': address,
    };
  }
}

class CreateShopOperatingDayModel {
  const CreateShopOperatingDayModel({
    required this.open,
    required this.close,
    required this.closed,
  });

  factory CreateShopOperatingDayModel.fromJson(Map<String, dynamic> json) {
    return CreateShopOperatingDayModel(
      open: (json['open'] ?? '').toString(),
      close: (json['close'] ?? '').toString(),
      closed: json['closed'] == true,
    );
  }

  final String open;
  final String close;
  final bool closed;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'open': open, 'close': close, 'closed': closed};
  }
}

class CreateShopResponseModel {
  const CreateShopResponseModel({
    required this.shopId,
    required this.userId,
    required this.restaurantName,
    required this.description,
    required this.image,
    required this.location,
    required this.operatingHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateShopResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> operatingRaw = _asMap(json['operatingHours']);

    final Map<String, CreateShopOperatingDayModel> mappedHours =
        <String, CreateShopOperatingDayModel>{};

    for (final MapEntry<String, dynamic> entry in operatingRaw.entries) {
      mappedHours[entry.key] = CreateShopOperatingDayModel.fromJson(
        _asMap(entry.value),
      );
    }

    return CreateShopResponseModel(
      shopId: (json['shopId'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      image: CreateShopImageModel.fromJson(_asMap(json['image'])),
      location: CreateShopLocationModel.fromJson(_asMap(json['location'])),
      operatingHours: mappedHours,
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  final String shopId;
  final String userId;
  final String restaurantName;
  final String description;
  final CreateShopImageModel image;
  final CreateShopLocationModel location;
  final Map<String, CreateShopOperatingDayModel> operatingHours;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'shopId': shopId,
      'userId': userId,
      'restaurantName': restaurantName,
      'description': description,
      'image': image.toJson(),
      'location': location.toJson(),
      'operatingHours': operatingHours.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CreateShopOperatingDayModel? get firstActiveOperatingDay {
    for (final String day in <String>[
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ]) {
      final CreateShopOperatingDayModel? slot = operatingHours[day];
      if (slot == null) continue;
      if (slot.open.trim().isNotEmpty || slot.close.trim().isNotEmpty) {
        return slot;
      }
    }
    return null;
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
