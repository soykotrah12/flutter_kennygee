import 'package:get/get.dart';

import '../../feature/auth/domain/repo/auth_repo.dart';
import '../../feature/auth/presentation/controller/auth_controller.dart';
import '../../feature/auth/presentation/controller/auth_flow_controller.dart';
import '../network/services/auth_storage_service.dart';
import '../network/services/onboarding_store_service.dart';

void setupController() {
  Get.lazyPut<AuthController>(
    () => AuthController(Get.find<AuthRepository>(), Get.find<AuthStorageService>()),
    fenix: true,
  );

  Get.lazyPut<AuthFlowController>(
    () => AuthFlowController(
      Get.find<AuthStorageService>(),
      Get.find<OnboardingStoreService>(),
    ),
    fenix: true,
  );
}
