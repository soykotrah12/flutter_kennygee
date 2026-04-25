import 'package:get/get.dart';

import '../../feature/auth/data/repo/auth_repo_impl.dart';
import '../../feature/auth/domain/repo/auth_repo.dart';
import '../../feature/home/data/repo/home_food_repo.dart';
import '../network/api_client.dart';
import '../network/repositories/wishlist_repository.dart';

void setupRepository() {
  Get.lazyPut<AuthRepository>(
    () => AuthRepositoryImpl(apiClient: Get.find<ApiClient>()),
    fenix: true,
  );

  Get.lazyPut<WishlistRepository>(
    () => WishlistRepository(apiClient: Get.find<ApiClient>()),
    fenix: true,
  );

  Get.lazyPut<HomeFoodRepository>(
    () => HomeFoodRepository(apiClient: Get.find<ApiClient>()),
    fenix: true,
  );
}
