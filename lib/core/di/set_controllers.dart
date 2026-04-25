import 'package:get/get.dart';

import '../common/controllers/wishlist_controller.dart';
import '../../feature/auth/domain/repo/auth_repo.dart';
import '../../feature/auth/presentation/controller/auth_controller.dart';
import '../../feature/auth/presentation/controller/auth_flow_controller.dart';
import '../../feature/home/data/repo/home_food_repo.dart';
import '../../feature/home/presentation/controller/home_food_controller.dart';
import '../network/services/auth_storage_service.dart';
import '../network/services/onboarding_store_service.dart';
import '../network/repositories/wishlist_repository.dart';

void setupController() {
  Get.lazyPut<AuthController>(
    () => AuthController(
      Get.find<AuthRepository>(),
      Get.find<AuthStorageService>(),
    ),
    fenix: true,
  );

  Get.lazyPut<AuthFlowController>(
    () => AuthFlowController(
      Get.find<AuthStorageService>(),
      Get.find<OnboardingStoreService>(),
      Get.find<AuthRepository>(),
    ),
    fenix: true,
  );

  Get.put<WishlistController>(
    WishlistController(Get.find<WishlistRepository>()),
    permanent: true,
  );

  Get.lazyPut<HomeFoodController>(
    () => HomeFoodController(Get.find<HomeFoodRepository>()),
    fenix: true,
  );
}
