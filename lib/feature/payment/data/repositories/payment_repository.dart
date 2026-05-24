import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../models/create_payment_response_model.dart';

class PaymentRepository {
  PaymentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<CreatePaymentResponseModel> createPayment({
    required String orderId,
  }) async {
    return createPaymentWithBody(<String, dynamic>{'orderId': orderId});
  }

  NetworkResult<CreatePaymentResponseModel> createPaymentWithBody(
    Map<String, dynamic> body,
  ) async {
    final String endpoint = ApiConstants.payment.createPayment;
    debugPrint('PAYMENT ENDPOINT => $endpoint');
    debugPrint('PAYMENT BODY => $body');

    final result = await _apiClient.post<CreatePaymentResponseModel>(
      endpoint,
      data: body,
      fromJsonT: (json) => CreatePaymentResponseModel.fromDynamic(json),
    );

    result.fold(
      (failure) {
        debugPrint(
          'PAYMENT CREATE FAILED => status:${failure.statusCode}, message:${failure.message}',
        );
      },
      (success) {
        debugPrint(
          'PAYMENT CREATE SUCCESS => status:${success.statusCode}, hasClientSecret:${success.data.clientSecret.trim().isNotEmpty}',
        );
      },
    );

    return result;
  }

  NetworkResult<bool> confirmPayment({required String paymentIntentId}) async {
    final String endpoint = ApiConstants.payment.confirmPayment;
    final Map<String, dynamic> body = <String, dynamic>{
      'paymentIntentId': paymentIntentId,
    };

    final result = await _apiClient.post<bool>(
      endpoint,
      data: body,
      fromJsonT: (_) => true,
    );

    result.fold(
      (failure) {
        debugPrint(
          'PAYMENT CONFIRM FAILED => status:${failure.statusCode}, message:${failure.message}',
        );
      },
      (success) {
        debugPrint(
          'PAYMENT CONFIRM SUCCESS => status:${success.statusCode}, confirmed:${success.data}',
        );
      },
    );

    return result;
  }
}
