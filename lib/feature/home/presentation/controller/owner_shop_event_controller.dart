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
    if (_isAccountDeleting) return;
    fetchOwnerEvents();
  }

  Future<void> fetchOwnerEvents() async {
    if (isLoading.value || _isAccountDeleting || isClosed) return;

    isLoading.value = true;
    error.value = '';

    if (_userId.isEmpty) {
      _userId = (await _authStorageService.getUserId() ?? '').trim();
    }
    if (_isAccountDeleting || isClosed) return;

    if (_userId.isEmpty) {
      error.value = 'Unable to find user id. Please login again.';
      isLoading.value = false;
      return;
    }

    final result = await _repository.fetchEventsByUserId(_userId);
    if (_isAccountDeleting || isClosed) return;

    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        if (_isNoEventsFailure(failure.statusCode, failure.message)) {
          events.clear();
          error.value = '';
        } else {
          error.value = _cleanErrorMessage(failure.message);
        }
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        events.assignAll(success.data);
      },
    );

    if (!_isAccountDeleting && !isClosed) {
      isLoading.value = false;
    }
  }

  bool _isNoEventsFailure(int statusCode, String message) {
    final String normalized = message.toLowerCase();
    return statusCode == 404 ||
        normalized.contains('no event') ||
        normalized.contains('not found');
  }

  String _cleanErrorMessage(String message) {
    final String trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return 'Unable to load events right now.';
    }
    return trimmed;
  }

  bool get _isAccountDeleting =>
      AuthStorageService.isClearingAfterAccountDelete;
}
