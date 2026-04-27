import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/food_model.dart';
import '../../data/repo/home_food_repo.dart';

class OwnerFoodListController extends GetxController {
  OwnerFoodListController(this._repository, {required this.shopId});

  final HomeFoodRepository _repository;
  final String shopId;

  final RxList<FoodModel> foods = <FoodModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  static String tagForShop(String shopId) => 'owner_food_list_$shopId';

  static OwnerFoodListController ensureInitialized(String shopId) {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeFoodRepository>()) {
      Get.lazyPut<HomeFoodRepository>(
        () => HomeFoodRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    final String tag = tagForShop(shopId);
    if (!Get.isRegistered<OwnerFoodListController>(tag: tag)) {
      Get.put<OwnerFoodListController>(
        OwnerFoodListController(Get.find<HomeFoodRepository>(), shopId: shopId),
        tag: tag,
      );
    }

    return Get.find<OwnerFoodListController>(tag: tag);
  }

  @override
  void onInit() {
    super.onInit();
    fetchShopFoods();
  }

  Future<void> fetchShopFoods() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchShopMenus(shopId: shopId);
    result.fold(
      (failure) {
        error.value = failure.message;
        foods.clear();
      },
      (success) {
        foods.assignAll(success.data);
      },
    );

    isLoading.value = false;
  }
}
