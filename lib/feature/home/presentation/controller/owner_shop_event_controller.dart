import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../data/model/event_model.dart';
import '../../data/repo/home_event_repo.dart';

OwnerShopEventController ensureOwnerShopEventController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<AuthStorageService>()) {
    Get.lazyPut<AuthStorageService>(() => AuthStorageService(), fenix: true);
  }

  if (!Get.isRegistered<HomeEventRepository>()) {
    Get.lazyPut<HomeEventRepository>(
      () => HomeEventRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<OwnerShopEventController>()) {
    Get.put<OwnerShopEventController>(
      OwnerShopEventController(
        repository: Get.find<HomeEventRepository>(),
        authStorageService: Get.find<AuthStorageService>(),
      ),
    );
  }

  return Get.find<OwnerShopEventController>();
}

class OwnerShopEventController extends GetxController {
  OwnerShopEventController({
    required HomeEventRepository repository,
    required AuthStorageService authStorageService,
  }) : _repository = repository,
       _authStorageService = authStorageService;

  final HomeEventRepository _repository;
  final AuthStorageService _authStorageService;

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  String _userId = '';

  @override
  void onInit() {
    super.onInit();
    fetchOwnerEvents();
  }

  Future<void> fetchOwnerEvents() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    if (_userId.isEmpty) {
      _userId = (await _authStorageService.getUserId() ?? '').trim();
    }

    if (_userId.isEmpty) {
      error.value = 'Unable to find user id. Please login again.';
      isLoading.value = false;
      return;
    }

    final result = await _repository.fetchEventsByUserId(_userId);

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
