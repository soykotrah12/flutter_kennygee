class RegisterResponseModel {
  final String email;
  final String role;

  RegisterResponseModel({required this.email, required this.role});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      email: json["email"] ?? "",
      role: json["role"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "role": role};
  }
}
