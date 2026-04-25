import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/food_model.dart';
import '../../data/repo/home_food_repo.dart';
import '../../data/repo/home_mock_data.dart';

class HomeFoodController extends GetxController {
  HomeFoodController(this._repository);

  final HomeFoodRepository _repository;

  final RxList<FoodModel> foods = <FoodModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  static HomeFoodController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeFoodRepository>()) {
      Get.lazyPut<HomeFoodRepository>(
        () => HomeFoodRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<HomeFoodController>()) {
      Get.put<HomeFoodController>(
        HomeFoodController(Get.find<HomeFoodRepository>()),
      );
    }

    return Get.find<HomeFoodController>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchNearbyFoods();
  }

  Future<void> fetchNearbyFoods() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchNearbyFoods(
      lat: 23.8103,
      lng: 90.4125,
    );

    result.fold(
      (failure) {
        error.value = failure.message;
        if (foods.isEmpty) {
          foods.assignAll(HomeMockData.foodList);
        }
      },
      (success) {
        if (success.data.isNotEmpty) {
          foods.assignAll(success.data);
        } else {
          foods.assignAll(HomeMockData.foodList);
        }
      },
    );

    isLoading.value = false;
  }
}
