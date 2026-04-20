class VerifyMailOtpResponseModel {
  const VerifyMailOtpResponseModel();

  factory VerifyMailOtpResponseModel.fromJson(dynamic json) {
    // The data field from API is null, so this is just a placeholder model
    // Success and message are handled by BaseResponse and returned via NetworkSuccess
    return const VerifyMailOtpResponseModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
