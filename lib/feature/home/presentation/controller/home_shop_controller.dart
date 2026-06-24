import 'dart:math';

import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../data/model/food_model.dart';
import '../../data/model/home_recommendation_item_model.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/repo/home_shop_repo.dart';

class HomeShopController extends GetxController {
  HomeShopController(this._repository);

  final HomeShopRepository _repository;

  final RxList<RestaurantModel> shops = <RestaurantModel>[].obs;

  // Recommended section data (cached in controller)
  final RxList<RestaurantModel> recommendedShops = <RestaurantModel>[].obs;
  final RxList<FoodModel> recommendedMenus = <FoodModel>[].obs;
  final RxList<HomeRecommendationItemModel> recommendedItems =
      <HomeRecommendationItemModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isRecommendedLoading = false.obs;
  final RxString error = ''.obs;
  final RxString recommendedError = ''.obs;

  static HomeShopController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeShopRepository>()) {
      Get.lazyPut<HomeShopRepository>(
        () => HomeShopRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<HomeShopController>()) {
      Get.put<HomeShopController>(
        HomeShopController(Get.find<HomeShopRepository>()),
      );
    }

    return Get.find<HomeShopController>();
  }

  @override
  void onInit() {
    super.onInit();
    if (_isAccountDeleting) return;
    fetchNearbyShops();
    fetchRecommendedShops();
  }

  Future<void> fetchNearbyShops() async {
    if (isLoading.value || _isAccountDeleting || isClosed) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchNearbyShops(
      lat: 23.8000,
      lng: 90.4000,
      radius: 5000,
    );

    if (_isAccountDeleting || isClosed) return;
    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        error.value = failure.message;
        shops.clear();
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        shops.assignAll(success.data);
      },
    );

    if (!_isAccountDeleting && !isClosed) {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecommendedShops() async {
    if (isRecommendedLoading.value || _isAccountDeleting || isClosed) return;

    isRecommendedLoading.value = true;
    recommendedError.value = '';

    final result = await _repository.fetchRecommendedShops(
      lat: 23.8000,
      lng: 90.4000,
      radius: 5000,
    );
    if (_isAccountDeleting || isClosed) return;

    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        recommendedError.value = failure.message;
        recommendedShops.clear();
        recommendedMenus.clear();
        recommendedItems.clear();
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        recommendedShops.assignAll(success.data.shops);
        recommendedMenus.assignAll(success.data.menus);

        final List<HomeRecommendationItemModel> mixed = _buildShuffledMixedList(
          shops: success.data.shops,
          menus: success.data.menus,
        );
        recommendedItems.assignAll(mixed);
      },
    );

    if (!_isAccountDeleting && !isClosed) {
      isRecommendedLoading.value = false;
    }
  }

  bool get _isAccountDeleting =>
      AuthStorageService.isClearingAfterAccountDelete;

  List<HomeRecommendationItemModel> _buildShuffledMixedList({
    required List<RestaurantModel> shops,
    required List<FoodModel> menus,
  }) {
    final Random random = Random();

    final List<RestaurantModel> shuffledShops = List<RestaurantModel>.from(
      shops,
    )..shuffle(random);
    final List<FoodModel> shuffledMenus = List<FoodModel>.from(menus)
      ..shuffle(random);

    final List<HomeRecommendationItemModel> mixed =
        <HomeRecommendationItemModel>[];

    int shopIndex = 0;
    int menuIndex = 0;
    bool addShopNext = random.nextBool();

    while (shopIndex < shuffledShops.length ||
        menuIndex < shuffledMenus.length) {
      if ((addShopNext && shopIndex < shuffledShops.length) ||
          menuIndex >= shuffledMenus.length) {
        mixed.add(_toRecommendationFromShop(shuffledShops[shopIndex]));
        shopIndex++;
      } else if (menuIndex < shuffledMenus.length) {
        mixed.add(_toRecommendationFromMenu(shuffledMenus[menuIndex]));
        menuIndex++;
      }

      addShopNext = !addShopNext;
    }

    return mixed;
  }

  HomeRecommendationItemModel _toRecommendationFromShop(RestaurantModel shop) {
    return HomeRecommendationItemModel(
      id: shop.id,
      type: 'shop',
      title: shop.name,
      image: shop.image,
      rating: shop.rating,
      distance: shop.distance,
      openingHours: shop.openingHours,
      restaurant: shop,
    );
  }

  HomeRecommendationItemModel _toRecommendationFromMenu(FoodModel menu) {
    return HomeRecommendationItemModel(
      id: menu.id,
      type: 'menu',
      title: menu.name,
      image: menu.image,
      rating: menu.rating,
      distance: menu.distance,
      openingHours: menu.openingHours,
      food: menu,
    );
  }
}
