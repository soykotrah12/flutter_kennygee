import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/repo/home_shop_repo.dart';

class HomeShopDetailsController extends GetxController {
  HomeShopDetailsController(this._repository);

  final HomeShopRepository _repository;

  final Rxn<RestaurantModel> restaurant = Rxn<RestaurantModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  static String tagForShop(String shopId) => 'shop_details_$shopId';

  static HomeShopDetailsController ensureInitialized(String shopId) {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeShopRepository>()) {
      Get.lazyPut<HomeShopRepository>(
        () => HomeShopRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    final String tag = tagForShop(shopId);

    if (!Get.isRegistered<HomeShopDetailsController>(tag: tag)) {
      Get.put<HomeShopDetailsController>(
        HomeShopDetailsController(Get.find<HomeShopRepository>()),
        tag: tag,
      );
    }

    return Get.find<HomeShopDetailsController>(tag: tag);
  }

  Future<void> fetchShopDetails({
    required String shopId,
    String? search,
  }) async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchShopDetails(
      shopId: shopId,
      lat: 23.8564,
      lng: 90.4354,
      search: search,
    );

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        restaurant.value = success.data;
      },
    );

    isLoading.value = false;
  }
}
