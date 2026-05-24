class CreatePaymentResponseModel {
  const CreatePaymentResponseModel({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  final String clientSecret;
  final String paymentIntentId;

  String get resolvedPaymentIntentId {
    if (paymentIntentId.trim().isNotEmpty) return paymentIntentId.trim();

    final String secret = clientSecret.trim();
    if (!secret.contains('_secret')) return '';
    return secret.split('_secret').first.trim();
  }

  factory CreatePaymentResponseModel.fromDynamic(dynamic value) {
    if (value is String) {
      final String clientSecret = value.trim();
      return CreatePaymentResponseModel(
        clientSecret: clientSecret,
        paymentIntentId: _extractPaymentIntentId(<String, dynamic>{
          'clientSecret': clientSecret,
        }),
      );
    }
    return CreatePaymentResponseModel.fromJson(_asMap(value));
  }

  factory CreatePaymentResponseModel.fromJson(Map<String, dynamic> json) {
    final String clientSecret = _extractClientSecret(json).trim();
    final String paymentIntentId = _extractPaymentIntentId(<String, dynamic>{
      ...json,
      'clientSecret': clientSecret,
    }).trim();
    return CreatePaymentResponseModel(
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
    );
  }
}

String _extractClientSecret(Map<String, dynamic> json) {
  final dynamic directClientSecret =
      json['clientSecret'] ?? json['client_secret'];
  if (directClientSecret is String && directClientSecret.trim().isNotEmpty) {
    return directClientSecret;
  }

  final dynamic paymentIntentClientSecret = json['paymentIntentClientSecret'];
  if (paymentIntentClientSecret is String &&
      paymentIntentClientSecret.trim().isNotEmpty) {
    return paymentIntentClientSecret;
  }

  final Map<String, dynamic> paymentIntent = _asMap(json['paymentIntent']);
  final dynamic nestedClientSecret = paymentIntent['client_secret'];
  if (nestedClientSecret is String && nestedClientSecret.trim().isNotEmpty) {
    return nestedClientSecret;
  }

  return '';
}

String _extractPaymentIntentId(Map<String, dynamic> json) {
  final dynamic directPaymentIntentId =
      json['paymentIntentId'] ?? json['payment_intent'];
  if (directPaymentIntentId is String &&
      directPaymentIntentId.trim().isNotEmpty) {
    return directPaymentIntentId;
  }

  final Map<String, dynamic> paymentIntent = _asMap(json['paymentIntent']);
  final dynamic nestedIntentId = paymentIntent['id'];
  if (nestedIntentId is String && nestedIntentId.trim().isNotEmpty) {
    return nestedIntentId;
  }

  final String clientSecret = _extractClientSecret(json).trim();
  if (clientSecret.contains('_secret')) {
    return clientSecret.split('_secret').first.trim();
  }

  return '';
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
