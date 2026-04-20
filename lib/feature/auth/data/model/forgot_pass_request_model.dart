class ForgotPassRequestModel {
  final String email;

  ForgotPassRequestModel({required this.email});

  // Convert from JSON → Model
  factory ForgotPassRequestModel.fromJson(Map<String, dynamic> json) {
    return ForgotPassRequestModel(email: json['email'] ?? '');
  }

  // Convert from Model → JSON
  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}
