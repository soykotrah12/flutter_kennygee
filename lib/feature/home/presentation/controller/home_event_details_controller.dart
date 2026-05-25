import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../data/model/event_model.dart';
import '../../data/repo/home_event_repo.dart';

class HomeEventDetailsController extends GetxController {
  HomeEventDetailsController(this._repository, this._authStorageService);

  final HomeEventRepository _repository;
  final AuthStorageService _authStorageService;

  final Rxn<EventModel> event = Rxn<EventModel>();
  final RxBool isLoading = false.obs;
  final RxBool isGoing = false.obs;
  final RxBool isLoadingGoing = false.obs;
  final RxBool hasGoingStatus = false.obs;
  final RxBool isToggleLoading = false.obs;
  final RxString error = ''.obs;

  int _goingRequestToken = 0;

  static String tagForEvent(String eventId) => eventId;

  static HomeEventDetailsController ensureInitialized(String eventId) {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeEventRepository>()) {
      Get.lazyPut<HomeEventRepository>(
        () => HomeEventRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthStorageService>()) {
      Get.lazyPut<AuthStorageService>(() => AuthStorageService(), fenix: true);
    }

    final String tag = tagForEvent(eventId);

    if (!Get.isRegistered<HomeEventDetailsController>(tag: tag)) {
      Get.put<HomeEventDetailsController>(
        HomeEventDetailsController(
          Get.find<HomeEventRepository>(),
          Get.find<AuthStorageService>(),
        ),
        tag: tag,
      );
    }

    return Get.find<HomeEventDetailsController>(tag: tag);
  }

  Future<void> fetchEventDetails(String eventId) async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchEventDetails(eventId);
    EventModel? fetchedEvent;

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        fetchedEvent = success.data;
      },
    );

    if (fetchedEvent != null) {
      event.value = fetchedEvent;
      await _syncGoingStateFromEvent(fetchedEvent!);
    }

    isLoading.value = false;
  }

  Future<void> fetchGoingStatus(String eventId) async {
    final int requestToken = ++_goingRequestToken;

    hasGoingStatus.value = false;
    isLoadingGoing.value = true;

    final result = await _repository.fetchEventDetails(eventId);

    if (requestToken != _goingRequestToken) {
      return;
    }

    EventModel? fetchedEvent;
    result.fold(
      (_) {
        isGoing.value = false;
      },
      (success) {
        fetchedEvent = success.data;
      },
    );

    if (fetchedEvent != null) {
      event.value = fetchedEvent;
      await _syncGoingStateFromEvent(fetchedEvent!);
    }

    hasGoingStatus.value = true;
    isLoadingGoing.value = false;
  }

  Future<String> toggleGoing(String eventId) async {
    if (isToggleLoading.value) return '';

    final int requestToken = ++_goingRequestToken;

    isToggleLoading.value = true;

    String message = '';
    bool didToggleSucceed = false;

    final result = await _repository.toggleGoing(eventId);
    result.fold(
      (failure) {
        message = failure.message;
      },
      (success) {
        if (requestToken != _goingRequestToken) return;
        isGoing.value = success.data.isGoing;
        hasGoingStatus.value = true;
        didToggleSucceed = true;
        message = success.message.isNotEmpty
            ? success.message
            : (success.data.isGoing
                  ? 'Marked as going successfully'
                  : 'Cancelled successfully');
      },
    );

    if (didToggleSucceed && requestToken == _goingRequestToken) {
      await fetchEventDetails(eventId);
    }

    isToggleLoading.value = false;
    return message;
  }

  Future<void> _syncGoingStateFromEvent(EventModel event) async {
    final String currentUserId = (await _authStorageService.getUserId() ?? '')
        .trim();

    final Set<String> normalizedGoingUsers = event.goingUsers
        .map((userId) => userId.trim())
        .where((userId) => userId.isNotEmpty)
        .toSet();

    final bool isGoing =
        currentUserId.isNotEmpty && normalizedGoingUsers.contains(currentUserId);

    this.isGoing.value = isGoing;
    hasGoingStatus.value = true;

    debugPrint('CURRENT USER ID => $currentUserId');
    debugPrint('EVENT GOING USERS => ${event.goingUsers}');
    debugPrint('IS CURRENT USER GOING => $isGoing');
  }
}
