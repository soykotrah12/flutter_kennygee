import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../common/constants/app_constants.dart';

class StripeInitializer {
  static Future<void> initStripe() async {
    Stripe.publishableKey = AppConstants.stripePublishableKey;

    try {
      await Stripe.instance.applySettings();
    } catch (error) {
      debugPrint('Stripe initialization failed: $error');
    }
  }
}
