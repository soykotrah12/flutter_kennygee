class StripeOnboardingResponseModel {
  const StripeOnboardingResponseModel({
    required this.accountId,
    required this.onboardingUrl,
    required this.expiresAt,
  });

  final String accountId;
  final String onboardingUrl;
  final int expiresAt;

  factory StripeOnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    return StripeOnboardingResponseModel(
      accountId: _asString(json['accountId']),
      onboardingUrl: _asString(json['onboardingUrl']),
      expiresAt: _asInt(json['expiresAt']),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
