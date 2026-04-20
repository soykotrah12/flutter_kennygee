class VerifyMailOtpRequest {
  final String email;
  final String otp;

  VerifyMailOtpRequest({required this.email, required this.otp});

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {"email": email, "otp": otp};
  }
}
