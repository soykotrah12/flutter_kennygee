class RefreshTokenResponseModel {
  final String accessToken;
  final String refreshToken;

  RefreshTokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseModel(
      accessToken: (json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? json['refresh_token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}
