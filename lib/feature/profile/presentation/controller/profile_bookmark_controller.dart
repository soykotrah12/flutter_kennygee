import 'package:get/get.dart';

import '../../../../core/common/controllers/wishlist_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../data/model/bookmark_shop_model.dart';
import '../../data/repo/profile_bookmark_repo.dart';

class ProfileBookmarkController extends GetxController {
  ProfileBookmarkController(this._repository);

  final ProfileBookmarkRepository _repository;

  final RxList<BookmarkShopModel> bookmarks = <BookmarkShopModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  static const String _bookmarkType = 'bookmark_shop';

  static ProfileBookmarkController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<ProfileBookmarkRepository>()) {
      Get.lazyPut<ProfileBookmarkRepository>(
        () => ProfileBookmarkRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProfileBookmarkController>()) {
      Get.put<ProfileBookmarkController>(
        ProfileBookmarkController(Get.find<ProfileBookmarkRepository>()),
      );
    }

    return Get.find<ProfileBookmarkController>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks({bool force = false}) async {
    if (isLoading.value && !force) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchMyBookmarks();
    result.fold(
      (failure) {
        error.value = failure.message;
        bookmarks.clear();
      },
      (success) {
        bookmarks.assignAll(success.data);

        if (Get.isRegistered<WishlistController>()) {
          final WishlistController stateController =
              Get.find<WishlistController>();
          final Iterable<String> bookmarkKeys = success.data
              .where((item) => item.id.trim().isNotEmpty)
              .map((item) => '${_bookmarkType}_${item.id.trim()}');
          stateController.syncFromFetchedItems(
            bookmarkKeys,
            type: _bookmarkType,
          );
        }
      },
    );

    isLoading.value = false;
  }
}
