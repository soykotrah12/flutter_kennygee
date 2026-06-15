import 'package:get/get.dart';

import '../../../../core/common/controllers/wishlist_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../data/model/wishlist_item_model.dart';
import '../../data/repo/home_wishlist_repo.dart';

enum WishlistTab { all, restaurant, food }

class HomeWishlistController extends GetxController {
  HomeWishlistController(this._repository);

  final HomeWishlistRepository _repository;

  static const double _defaultLat = 23.8103;
  static const double _defaultLng = 90.4125;
  static const int _defaultRadius = 5000;

  final RxList<WishlistItemModel> items = <WishlistItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<WishlistTab> activeTab = WishlistTab.all.obs;
  int _requestSequence = 0;

  static HomeWishlistController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeWishlistRepository>()) {
      Get.lazyPut<HomeWishlistRepository>(
        () => HomeWishlistRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<HomeWishlistController>()) {
      Get.put<HomeWishlistController>(
        HomeWishlistController(Get.find<HomeWishlistRepository>()),
      );
    }

    return Get.find<HomeWishlistController>();
  }

  @override
  void onInit() {
    super.onInit();
    if (_isAccountDeleting) return;
    fetchWishlist(tab: WishlistTab.all);
  }

  Future<void> changeTab(WishlistTab tab) async {
    if (_isAccountDeleting || isClosed) return;
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    await fetchWishlist(tab: tab);
  }

  Future<void> refreshCurrentTab() async {
    if (_isAccountDeleting || isClosed) return;
    await fetchWishlist(tab: activeTab.value);
  }

  Future<void> fetchWishlist({WishlistTab? tab}) async {
    if (_isAccountDeleting || isClosed) return;

    final WishlistTab targetTab = tab ?? activeTab.value;
    final int requestId = ++_requestSequence;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchMyWishlist(
      type: _typeQuery(targetTab),
      lat: _defaultLat,
      lng: _defaultLng,
      radius: _defaultRadius,
    );

    if (_isAccountDeleting || isClosed) return;
    if (requestId != _requestSequence) {
      return;
    }

    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        error.value = failure.message;
        items.clear();
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        items.assignAll(success.data);

        final WishlistController wishlistController =
            Get.find<WishlistController>();
        final Iterable<String> fetchedKeys = success.data
            .where((item) => item.id.trim().isNotEmpty)
            .map((item) => '${item.type.apiType}_${item.id}');

        if (targetTab == WishlistTab.all) {
          wishlistController.syncFromFetchedItems(
            fetchedKeys.where((key) => key.startsWith('shop_')),
            type: 'shop',
          );
          wishlistController.syncFromFetchedItems(
            fetchedKeys.where((key) => key.startsWith('menu_')),
            type: 'menu',
          );
        } else if (targetTab == WishlistTab.restaurant) {
          wishlistController.syncFromFetchedItems(
            fetchedKeys.where((key) => key.startsWith('shop_')),
            type: 'shop',
          );
        } else {
          wishlistController.syncFromFetchedItems(
            fetchedKeys.where((key) => key.startsWith('menu_')),
            type: 'menu',
          );
        }
      },
    );

    if (!_isAccountDeleting && !isClosed) {
      isLoading.value = false;
    }
  }

  bool get _isAccountDeleting =>
      AuthStorageService.isClearingAfterAccountDelete;

  String _typeQuery(WishlistTab tab) {
    switch (tab) {
      case WishlistTab.all:
        return 'all';
      case WishlistTab.restaurant:
        return 'restaurant';
      case WishlistTab.food:
        return 'food';
    }
  }
}
