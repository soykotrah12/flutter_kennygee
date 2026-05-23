import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/repo/home_shop_repo.dart';

class HomeShopDetailsController extends GetxController {
  HomeShopDetailsController(this._repository, {required this.shopId});

  final HomeShopRepository _repository;
  final String shopId;

  final Rxn<RestaurantModel> restaurant = Rxn<RestaurantModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  StreamSubscription<ApiMutationEvent>? _mutationSubscription;
  Timer? _mutationRefreshDebounce;
  bool _queuedRefresh = false;
  int _fetchCount = 0;
  static int _initCount = 0;

  static String tagForShop(String shopId) => 'shop_details_$shopId';

  static HomeShopDetailsController ensureInitialized(String shopId) {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeShopRepository>()) {
      Get.lazyPut<HomeShopRepository>(
        () => HomeShopRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    final String tag = tagForShop(shopId);

    if (!Get.isRegistered<HomeShopDetailsController>(tag: tag)) {
      Get.put<HomeShopDetailsController>(
        HomeShopDetailsController(
          Get.find<HomeShopRepository>(),
          shopId: shopId,
        ),
        tag: tag,
      );
    }

    return Get.find<HomeShopDetailsController>(tag: tag);
  }

  Future<void> fetchShopDetails({
    required String shopId,
    bool force = false,
  }) async {
    if (isLoading.value) {
      if (force) _queuedRefresh = true;
      return;
    }

    _fetchCount++;
    debugPrint(
      '[HomeShopDetailsController] fetchShopDetails #$_fetchCount shopId=$shopId force=$force',
    );

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchShopDetails(shopId: shopId);

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        restaurant.value = success.data;
      },
    );

    isLoading.value = false;
    if (_queuedRefresh) {
      _queuedRefresh = false;
      fetchShopDetails(shopId: shopId);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initCount++;
    debugPrint(
      '[HomeShopDetailsController] onInit count=$_initCount shopId=$shopId',
    );

    _mutationSubscription = ApiClient.mutationStream.listen((event) {
      if (_shouldRefresh(event)) {
        _mutationRefreshDebounce?.cancel();
        _mutationRefreshDebounce = Timer(const Duration(milliseconds: 450), () {
          fetchShopDetails(shopId: shopId, force: true);
        });
      }
    });
  }

  bool _shouldRefresh(ApiMutationEvent event) {
    final String endpoint = event.endpoint.toLowerCase();
    if (endpoint.contains('/review') || endpoint.contains('/shop/')) {
      final dynamic rawData = event.data;
      if (rawData is Map<String, dynamic>) {
        final String eventShopId = (rawData['shopId'] ?? '').toString().trim();
        if (eventShopId.isNotEmpty) {
          return eventShopId == shopId;
        }
      }
      return true;
    }
    return false;
  }

  @override
  void onClose() {
    _mutationRefreshDebounce?.cancel();
    _mutationSubscription?.cancel();
    super.onClose();
  }
}
