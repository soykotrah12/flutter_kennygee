import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../data/model/food_model.dart';
import '../../data/repo/home_food_repo.dart';

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
    if (_isAccountDeleting) return;
    fetchNearbyFoods();
  }

  Future<void> fetchNearbyFoods() async {
    if (isLoading.value || _isAccountDeleting || isClosed) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchNearbyFoods(
      lat: 23.8103,
      lng: 90.4125,
    );

    if (_isAccountDeleting || isClosed) return;
    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        error.value = failure.message;
        foods.clear();
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        foods.assignAll(success.data);
      },
    );

    if (!_isAccountDeleting && !isClosed) {
      isLoading.value = false;
    }
  }

  bool get _isAccountDeleting =>
      AuthStorageService.isClearingAfterAccountDelete;
}
