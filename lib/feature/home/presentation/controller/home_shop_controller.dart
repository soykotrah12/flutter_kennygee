import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/repo/home_shop_repo.dart';

class HomeShopController extends GetxController {
  HomeShopController(this._repository);

  final HomeShopRepository _repository;

  final RxList<RestaurantModel> shops = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> recommendedShops = <RestaurantModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRecommendedLoading = false.obs;
  final RxString error = ''.obs;
  final RxString recommendedError = ''.obs;

  static HomeShopController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeShopRepository>()) {
      Get.lazyPut<HomeShopRepository>(
        () => HomeShopRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<HomeShopController>()) {
      Get.put<HomeShopController>(HomeShopController(Get.find<HomeShopRepository>()));
    }

    return Get.find<HomeShopController>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchNearbyShops();
    fetchRecommendedShops();
  }

  Future<void> fetchNearbyShops() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchNearbyShops(
      lat: 23.8000,
      lng: 90.4000,
      radius: 5000,
    );

    result.fold(
      (failure) {
        error.value = failure.message;
        shops.clear();
      },
      (success) {
        shops.assignAll(success.data);
      },
    );

    isLoading.value = false;
  }

  Future<void> fetchRecommendedShops() async {
    if (isRecommendedLoading.value) return;

    isRecommendedLoading.value = true;
    recommendedError.value = '';

    final result = await _repository.fetchRecommendedShops(
      lat: 23.8103,
      lng: 90.4125,
      radius: 5000,
    );

    result.fold(
      (failure) {
        recommendedError.value = failure.message;
        recommendedShops.clear();
      },
      (success) {
        recommendedShops.assignAll(success.data);
      },
    );

    isRecommendedLoading.value = false;
  }
}
