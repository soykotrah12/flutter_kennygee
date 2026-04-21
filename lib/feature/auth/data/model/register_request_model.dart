class RegisterRequestModel {
  final String name;
  final String email;
  final String? phoneNumber;
  final String password;
  final String confirmPassword;
  final String role;
  final String? shopName;

  RegisterRequestModel({
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.shopName,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "name": name,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "role": role,
    };
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      data["phoneNumber"] = phoneNumber!.trim();
    }
    if (shopName != null) data["shopName"] = shopName;
    return data;
  }
}
