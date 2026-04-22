class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isEmailVerified;
  final String createdAt;
  final String updatedAt;
  final int v;
  final ProfileImageModel profileImage;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.profileImage,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final imageJson = _asMap(json['profileImage'] ?? json['avatar']);

    return UserProfileModel(
      id: _asString(json['_id']).isNotEmpty
          ? _asString(json['_id'])
          : _asString(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phoneNumber: _asString(json['phoneNumber']).isNotEmpty
          ? _asString(json['phoneNumber'])
          : _asString(json['phone']),
      role: _asString(json['role']),
      isEmailVerified: _asBool(json['isEmailVerified']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
      v: _asInt(json['__v']),
      profileImage: ProfileImageModel.fromJson(imageJson),
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    bool? isEmailVerified,
    String? createdAt,
    String? updatedAt,
    int? v,
    ProfileImageModel? profileImage,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

class ProfileImageModel {
  final String publicId;
  final String url;

  const ProfileImageModel({required this.publicId, required this.url});

  factory ProfileImageModel.fromJson(Map<String, dynamic> json) {
    return ProfileImageModel(
      publicId: _asString(json['public_id']).isNotEmpty
          ? _asString(json['public_id'])
          : _asString(json['publicId']),
      url: _asString(json['url']),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value != 0;
  return false;
}

int _asInt(dynamic value) {
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
