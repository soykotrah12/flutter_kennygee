import 'package:get/get.dart';

import '../network/services/onboarding_store_service.dart';

void setupServices() {
  Get.lazyPut<OnboardingStoreService>(() => OnboardingStoreService(), fenix: true);
}
