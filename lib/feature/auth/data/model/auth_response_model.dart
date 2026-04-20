class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String id;
  final User user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.id,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json["accessToken"] ?? "",
      refreshToken: json["refreshToken"] ?? "",
      role: json["role"] ?? "",
      id: json["_id"] ?? "",
      user: User.fromJson(json["user"] ?? {}),
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
  final String createdAt;
  final String updatedAt;
  final int v;

  User({
    required this.avatar,
    required this.verificationInfo,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
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
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      avatar: Avatar.fromJson(json["avatar"] ?? {}),
      verificationInfo: VerificationInfo.fromJson(
        json["verificationInfo"] ?? {},
      ),
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      countryCode: json["countryCode"] ?? "",
      role: json["role"] ?? "",
      shopName: json["shopName"] ?? "",
      shopLogo: Avatar.fromJson(json["shopLogo"] ?? {}),
      gender: json["gender"] as String?,
      sportPreferences: List<String>.from(json["sportPreferences"] ?? []),
      passwordResetToken: json["password_reset_token"] ?? "",
      refreshToken: json["refreshToken"] ?? "",
      currentPlan: json["currentPlan"] ?? "",
      isSubscribed: json["isSubscribed"] ?? false,
      purchases: List<dynamic>.from(json["purchases"] ?? []),
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      v: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "avatar": avatar.toJson(),
      "verificationInfo": verificationInfo.toJson(),
      "_id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "countryCode": countryCode,
      "role": role,
      "shopName": shopName,
      "shopLogo": shopLogo.toJson(),
      "gender": gender,
      "sportPreferences": sportPreferences,
      "password_reset_token": passwordResetToken,
      "refreshToken": refreshToken,
      "currentPlan": currentPlan,
      "isSubscribed": isSubscribed,
      "purchases": purchases,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
    };
  }
}

class Avatar {
  final String publicId;
  final String url;

  Avatar({required this.publicId, required this.url});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(publicId: json["public_id"] ?? "", url: json["url"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"public_id": publicId, "url": url};
  }
}

class VerificationInfo {
  final bool verified;
  final String token;

  VerificationInfo({required this.verified, required this.token});

  factory VerificationInfo.fromJson(Map<String, dynamic> json) {
    return VerificationInfo(
      verified: json["verified"] ?? false,
      token: json["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"verified": verified, "token": token};
  }
}
