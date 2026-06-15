class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String _role;
  final String _id;
  final User user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required String role,
    required String id,
    required this.user,
  }) : _role = role,
       _id = id;

  String get role => _role.isNotEmpty ? _role : user.role;
  String get id => _id.isNotEmpty ? _id : user.id;
  String get email => user.email;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(_asMap(json["user"]));
    final accessToken = _asString(
      json["accessToken"] ?? json["access_token"] ?? json["token"] ?? json["jwt"],
    );
    final refreshToken = _asString(
      json["refreshToken"] ?? json["refresh_token"] ?? user.refreshToken,
    );

    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: _asString(json["role"]),
      id: _asString(json["_id"]),
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "role": role,
      "_id": id,
      "user": user.toJson(),
    };
  }
}

class User {
  final Avatar avatar;
  final VerificationInfo verificationInfo;
  final String id;
  final String name;
  final String email;
  final String phone;
  final String countryCode;
  final String role;
  final String? shopName;
  final Avatar shopLogo;
  final String? gender;
  final List<String> sportPreferences;
  final String passwordResetToken;
  final String refreshToken;
  final String currentPlan;
  final bool isSubscribed;
  final List<dynamic> purchases;
  final bool isEmailVerified;
  final String createdAt;
  final String updatedAt;
  final int v;

  User({
    required this.avatar,
    required this.verificationInfo,
    required this.id,
    required this.name,
    required this.email,
    this.phone = "",
    required this.countryCode,
    required this.role,
    this.shopName,
    required this.shopLogo,
    this.gender,
    required this.sportPreferences,
    required this.passwordResetToken,
    required this.refreshToken,
    required this.currentPlan,
    required this.isSubscribed,
    required this.purchases,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      avatar: Avatar.fromJson(_asMap(json["avatar"])),
      verificationInfo: VerificationInfo.fromJson(
        _asMap(json["verificationInfo"]),
      ),
      id: _asString(json["_id"]).isNotEmpty
          ? _asString(json["_id"])
          : _asString(json["id"]),
      name: _asString(json["name"]),
      email: _asString(json["email"]),
      phone: _asString(json["phone"]).isNotEmpty
          ? _asString(json["phone"])
          : _asString(json["phoneNumber"]),
      countryCode: _asString(json["countryCode"]),
      role: _asString(json["role"]),
      shopName: _asString(json["shopName"]).isEmpty
          ? null
          : _asString(json["shopName"]),
      shopLogo: Avatar.fromJson(_asMap(json["shopLogo"])),
      gender: _asString(json["gender"]).isEmpty
          ? null
          : _asString(json["gender"]),
      sportPreferences: _asStringList(json["sportPreferences"]),
      passwordResetToken: _asString(
        json["password_reset_token"] ?? json["passwordResetToken"],
      ),
      refreshToken: _asString(json["refreshToken"]),
      currentPlan: _asString(json["currentPlan"]),
      isSubscribed: _asBool(json["isSubscribed"]),
      purchases: json["purchases"] is List
          ? json["purchases"] as List<dynamic>
          : const [],
      isEmailVerified: _asBool(json["isEmailVerified"]),
      createdAt: _asString(json["createdAt"]),
      updatedAt: _asString(json["updatedAt"]),
      v: _asInt(json["__v"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "avatar": avatar.toJson(),
      "verificationInfo": verificationInfo.toJson(),
      "_id": id,
      "name": name,
      "email": email,
      "phoneNumber": phone,
      "countryCode": countryCode,
      "role": role,
      "shopName": shopName,
      "shopLogo": shopLogo.toJson(),
      "gender": gender,
      "sportPreferences": sportPreferences,
      "passwordResetToken": passwordResetToken,
      "refreshToken": refreshToken,
      "currentPlan": currentPlan,
      "isSubscribed": isSubscribed,
      "purchases": purchases,
      "isEmailVerified": isEmailVerified,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
    };
  }
}

class Avatar {
  final String publicId;
  final String url;

  const Avatar({required this.publicId, required this.url});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      publicId: _asString(json["public_id"]).isNotEmpty
          ? _asString(json["public_id"])
          : _asString(json["publicId"]),
      url: _asString(json["url"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {"public_id": publicId, "url": url};
  }
}

class VerificationInfo {
  final bool verified;
  final String token;

  const VerificationInfo({required this.verified, required this.token});

  factory VerificationInfo.fromJson(Map<String, dynamic> json) {
    return VerificationInfo(
      verified: _asBool(json["verified"]),
      token: _asString(json["token"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {"verified": verified, "token": token};
  }
}

String _asString(dynamic value) => value?.toString() ?? "";

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == "true";
  if (value is num) return value != 0;
  return false;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "") ?? 0;
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
