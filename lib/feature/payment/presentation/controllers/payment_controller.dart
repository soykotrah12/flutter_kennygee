import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/create_payment_response_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/services/payment_service.dart';

PaymentController ensurePaymentController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<PaymentRepository>()) {
    Get.lazyPut<PaymentRepository>(
      () => PaymentRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<PaymentService>()) {
    Get.lazyPut<PaymentService>(
      () => PaymentService(repository: Get.find<PaymentRepository>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<PaymentController>()) {
    Get.lazyPut<PaymentController>(
      () => PaymentController(Get.find<PaymentService>()),
      fenix: true,
    );
  }

  return Get.find<PaymentController>();
}

class PaymentController extends GetxController {
  PaymentController(this._paymentService);

  final PaymentService _paymentService;

  final RxBool isPaymentLoading = false.obs;
  final RxString paymentMessage = ''.obs;

  Future<bool> payForOrder({required String orderId}) async {
    final String trimmedOrderId = orderId.trim();
    if (trimmedOrderId.isEmpty) {
      paymentMessage.value = PaymentService.createPaymentErrorMessage;
      return false;
    }

    return _payWithCreateBody(
      createBody: <String, dynamic>{'orderId': trimmedOrderId},
      createLogLabel: 'CREATE PAYMENT ORDER ID => $trimmedOrderId',
    );
  }

  Future<bool> payForPlan({required String planId, required num price}) async {
    final String trimmedPlanId = planId.trim();
    if (trimmedPlanId.isEmpty) {
      paymentMessage.value = PaymentService.createPaymentErrorMessage;
      return false;
    }
    if (price <= 0) {
      paymentMessage.value = PaymentService.createPaymentErrorMessage;
      return false;
    }

    return _payWithCreateBody(
      createBody: <String, dynamic>{'planId': trimmedPlanId, 'price': price},
      createLogLabel:
          'CREATE PLAN PAYMENT BODY => {"planId":"$trimmedPlanId","price":$price}',
    );
  }

  Future<bool> _payWithCreateBody({
    required Map<String, dynamic> createBody,
    required String createLogLabel,
  }) async {
    if (isPaymentLoading.value) return false;

    isPaymentLoading.value = true;
    paymentMessage.value = '';

    try {
      debugPrint(createLogLabel);
      final CreatePaymentResponseModel? createPaymentResponse =
          await _paymentService.createPaymentWithBody(createBody);

      if (createPaymentResponse == null) {
        paymentMessage.value =
            _paymentService.lastErrorMessage ??
            PaymentService.createPaymentErrorMessage;
        return false;
      }

      final String clientSecret = createPaymentResponse.clientSecret.trim();
      debugPrint('CLIENT SECRET => $clientSecret');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Kenezee',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final String paymentIntentId = createPaymentResponse
          .resolvedPaymentIntentId
          .trim();
      debugPrint('PAYMENT INTENT ID => $paymentIntentId');
      debugPrint(
        'CONFIRM PAYMENT BODY => {"paymentIntentId": "$paymentIntentId"}',
      );

      final bool confirmed = await _paymentService.confirmPayment(
        paymentIntentId: paymentIntentId,
      );
      if (!confirmed) {
        paymentMessage.value =
            _paymentService.lastErrorMessage ??
            PaymentService.confirmPaymentErrorMessage;
        return false;
      }

      paymentMessage.value = 'Payment successful.';
      return true;
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        paymentMessage.value = 'Payment was canceled.';
      } else {
        paymentMessage.value = 'Payment could not be completed.';
      }
      return false;
    } catch (_) {
      paymentMessage.value = 'Payment failed. Please try again.';
      return false;
    } finally {
      isPaymentLoading.value = false;
    }
  }
}
