import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/event_model.dart';
import '../../data/repo/home_event_repo.dart';

class HomeEventDetailsController extends GetxController {
  HomeEventDetailsController(this._repository);

  final HomeEventRepository _repository;

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

    final String tag = tagForEvent(eventId);

    if (!Get.isRegistered<HomeEventDetailsController>(tag: tag)) {
      Get.put<HomeEventDetailsController>(
        HomeEventDetailsController(Get.find<HomeEventRepository>()),
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

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        event.value = success.data;
      },
    );

    isLoading.value = false;
  }

  Future<void> fetchGoingStatus(String eventId) async {
    final int requestToken = ++_goingRequestToken;

    hasGoingStatus.value = false;
    isLoadingGoing.value = true;

    final result = await _repository.fetchGoingStatus(eventId);

    if (requestToken != _goingRequestToken) {
      return;
    }

    result.fold(
      (_) {
        isGoing.value = false;
      },
      (success) {
        isGoing.value = success.data.isGoing;
        print('GET isGoing: ${success.data.isGoing}');
      },
    );

    hasGoingStatus.value = true;
    isLoadingGoing.value = false;
  }

  Future<String> toggleGoing(String eventId) async {
    if (isToggleLoading.value) return '';

    final int requestToken = ++_goingRequestToken;

    isToggleLoading.value = true;

    String message = '';

    final result = await _repository.toggleGoing(eventId);
    result.fold(
      (failure) {
        message = failure.message;
      },
      (success) {
        if (requestToken != _goingRequestToken) return;
        isGoing.value = success.data.isGoing;
        hasGoingStatus.value = true;
        print('PATCH isGoing: ${success.data.isGoing}');
        message = success.message.isNotEmpty
            ? success.message
            : (success.data.isGoing
                  ? 'Marked as going successfully'
                  : 'Cancelled successfully');
      },
    );

    isToggleLoading.value = false;
    return message;
  }
}
