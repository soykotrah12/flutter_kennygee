import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/event_model.dart';
import '../../data/repo/home_event_repo.dart';

class HomeEventController extends GetxController {
  HomeEventController(this._repository);

  final HomeEventRepository _repository;

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  static HomeEventController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeEventRepository>()) {
      Get.lazyPut<HomeEventRepository>(
        () => HomeEventRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<HomeEventController>()) {
      Get.put<HomeEventController>(
        HomeEventController(Get.find<HomeEventRepository>()),
      );
    }

    return Get.find<HomeEventController>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchEvents();

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        events.assignAll(success.data);
      },
    );

    isLoading.value = false;
  }
}
