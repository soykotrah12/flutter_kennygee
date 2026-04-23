import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/repo/home_mock_data.dart';
import '../../data/repo/home_shop_repo.dart';

class HomeShopController extends GetxController {
  HomeShopController(this._repository);

  final HomeShopRepository _repository;

  final RxList<RestaurantModel> shops = <RestaurantModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

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
        if (shops.isEmpty) {
          shops.assignAll(HomeMockData.restaurantList);
        }
      },
      (success) {
        final List<RestaurantModel> apiItems = success.data;
        if (apiItems.isNotEmpty) {
          shops.assignAll(apiItems);
        } else {
          shops.assignAll(HomeMockData.restaurantList);
        }
      },
    );

    isLoading.value = false;
  }
}
