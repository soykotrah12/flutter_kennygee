import 'package:dartz/dartz.dart';

import '../../../../core/network/models/network_failure.dart';
import '../../../../core/network/models/network_success.dart';
import '../repositories/payment_repository.dart';
import '../models/create_payment_response_model.dart';

class PaymentService {
  PaymentService({required PaymentRepository repository})
    : _repository = repository;

  static const String createPaymentErrorMessage =
      'Payment could not be created. Please try again.';
  static const String confirmPaymentErrorMessage =
      'Payment confirmation failed. Please try again.';

  final PaymentRepository _repository;

  String? _lastErrorMessage;

  String? get lastErrorMessage => _lastErrorMessage;

  Future<CreatePaymentResponseModel?> createPayment({
    required String orderId,
  }) async {
    final String trimmedOrderId = orderId.trim();
    if (trimmedOrderId.isEmpty) {
      _lastErrorMessage = createPaymentErrorMessage;
      return null;
    }

    final result = await _repository.createPayment(orderId: trimmedOrderId);
    return _resolveCreatePaymentResult(result);
  }

  Future<CreatePaymentResponseModel?> createPaymentWithBody(
    Map<String, dynamic> body,
  ) async {
    if (body.isEmpty) {
      _lastErrorMessage = createPaymentErrorMessage;
      return null;
    }

    final result = await _repository.createPaymentWithBody(body);
    return _resolveCreatePaymentResult(result);
  }

  CreatePaymentResponseModel? _resolveCreatePaymentResult(
    Either<NetworkFailure, NetworkSuccess<CreatePaymentResponseModel>> result,
  ) {
    return result.fold(
      (failure) {
        _lastErrorMessage = createPaymentErrorMessage;
        return null;
      },
      (success) {
        final CreatePaymentResponseModel createResponse = success.data;
        final String clientSecret = createResponse.clientSecret.trim();
        if (clientSecret.isEmpty) {
          _lastErrorMessage = createPaymentErrorMessage;
          return null;
        }

        _lastErrorMessage = null;
        return createResponse;
      },
    );
  }

  Future<bool> confirmPayment({required String paymentIntentId}) async {
    final String trimmedPaymentIntentId = paymentIntentId.trim();
    if (trimmedPaymentIntentId.isEmpty) {
      _lastErrorMessage = confirmPaymentErrorMessage;
      return false;
    }

    final result = await _repository.confirmPayment(
      paymentIntentId: trimmedPaymentIntentId,
    );

    return result.fold(
      (failure) {
        _lastErrorMessage = confirmPaymentErrorMessage;
        return false;
      },
      (success) {
        _lastErrorMessage = null;
        return success.data;
      },
    );
  }
}
