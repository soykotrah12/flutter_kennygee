import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/food_model.dart';
import '../../data/repo/home_food_repo.dart';

class HomeFoodDetailsController extends GetxController {
  HomeFoodDetailsController(this._repository);

  final HomeFoodRepository _repository;

  final Rxn<FoodModel> menu = Rxn<FoodModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  static String tagForMenu(String menuId) => 'menu_details_$menuId';

  static HomeFoodDetailsController ensureInitialized(String menuId) {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeFoodRepository>()) {
      Get.lazyPut<HomeFoodRepository>(
        () => HomeFoodRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    final String tag = tagForMenu(menuId);

    if (!Get.isRegistered<HomeFoodDetailsController>(tag: tag)) {
      Get.put<HomeFoodDetailsController>(
        HomeFoodDetailsController(Get.find<HomeFoodRepository>()),
        tag: tag,
      );
    }

    return Get.find<HomeFoodDetailsController>(tag: tag);
  }

  Future<void> fetchMenuDetails({required String menuId}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchMenuDetails(
      menuId: menuId,
      lat: 23.8103,
      lng: 90.4125,
    );

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        menu.value = success.data;
      },
    );

    isLoading.value = false;
  }
}
