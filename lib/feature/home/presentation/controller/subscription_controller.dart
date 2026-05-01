import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/subscription_plan_model.dart';
import '../../data/repo/subscription_repo.dart';

SubscriptionController ensureSubscriptionController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<SubscriptionRepository>()) {
    Get.lazyPut<SubscriptionRepository>(
      () => SubscriptionRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<SubscriptionController>()) {
    Get.put<SubscriptionController>(
      SubscriptionController(Get.find<SubscriptionRepository>()),
    );
  }

  return Get.find<SubscriptionController>();
}

class SubscriptionController extends GetxController {
  SubscriptionController(this._repository);

  final SubscriptionRepository _repository;

  final RxList<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchPlans();
    result.fold(
      (failure) {
        error.value = failure.message;
        plans.clear();
      },
      (success) {
        plans.assignAll(success.data);
      },
    );

    isLoading.value = false;
  }
}
