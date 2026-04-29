import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/owner_analytics_model.dart';
import '../../data/repo/owner_analytics_repo.dart';

OwnerAnalyticsController ensureOwnerAnalyticsController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<OwnerAnalyticsRepository>()) {
    Get.lazyPut<OwnerAnalyticsRepository>(
      () => OwnerAnalyticsRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<OwnerAnalyticsController>()) {
    Get.put<OwnerAnalyticsController>(
      OwnerAnalyticsController(Get.find<OwnerAnalyticsRepository>()),
    );
  }

  return Get.find<OwnerAnalyticsController>();
}

class OwnerAnalyticsController extends GetxController {
  OwnerAnalyticsController(this._repository);

  final OwnerAnalyticsRepository _repository;

  final Rxn<OwnerAnalyticsModel> analytics = Rxn<OwnerAnalyticsModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchOwnerAnalytics();

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        analytics.value = success.data;
      },
    );

    isLoading.value = false;
  }
}
