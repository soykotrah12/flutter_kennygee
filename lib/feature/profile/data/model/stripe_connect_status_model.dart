class StripeConnectStatusModel {
  const StripeConnectStatusModel({
    required this.connected,
    required this.accountId,
    required this.status,
  });

  final bool connected;
  final String accountId;
  final StripeAccountStatusModel status;

  factory StripeConnectStatusModel.fromJson(Map<String, dynamic> json) {
    return StripeConnectStatusModel(
      connected: _asBool(json['connected']),
      accountId: _asString(json['accountId']),
      status: StripeAccountStatusModel.fromJson(_asMap(json['status'])),
    );
  }
}

class StripeAccountStatusModel {
  const StripeAccountStatusModel({
    required this.onboardingComplete,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.detailsSubmitted,
    required this.lastSyncedAt,
  });

  final bool onboardingComplete;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;
  final String lastSyncedAt;

  factory StripeAccountStatusModel.fromJson(Map<String, dynamic> json) {
    return StripeAccountStatusModel(
      onboardingComplete: _asBool(json['onboardingComplete']),
      chargesEnabled: _asBool(json['chargesEnabled']),
      payoutsEnabled: _asBool(json['payoutsEnabled']),
      detailsSubmitted: _asBool(json['detailsSubmitted']),
      lastSyncedAt: _asString(json['lastSyncedAt']),
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

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
