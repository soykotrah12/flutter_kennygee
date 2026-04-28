import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/local/owner_shop_local_store.dart';
import '../../data/model/create_shop_request_model.dart';
import '../../data/model/create_shop_response_model.dart';
import '../../data/repo/create_shop_repo.dart';

OwnerShopController ensureOwnerShopController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<AuthStorageService>()) {
    Get.lazyPut<AuthStorageService>(() => AuthStorageService(), fenix: true);
  }

  if (!Get.isRegistered<CreateShopRepository>()) {
    Get.lazyPut<CreateShopRepository>(
      () => CreateShopRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<OwnerShopLocalStore>()) {
    Get.lazyPut<OwnerShopLocalStore>(() => OwnerShopLocalStore(), fenix: true);
  }

  if (!Get.isRegistered<OwnerShopController>()) {
    Get.put<OwnerShopController>(
      OwnerShopController(
        repository: Get.find<CreateShopRepository>(),
        authStorageService: Get.find<AuthStorageService>(),
        localStore: Get.find<OwnerShopLocalStore>(),
      ),
    );
  }

  return Get.find<OwnerShopController>();
}

class ShopDayFormValue {
  const ShopDayFormValue({
    required this.open,
    required this.close,
    required this.closed,
  });

  final String open;
  final String close;
  final bool closed;
}

class OwnerShopController extends GetxController {
  OwnerShopController({
    required CreateShopRepository repository,
    required AuthStorageService authStorageService,
    required OwnerShopLocalStore localStore,
  }) : _repository = repository,
       _authStorageService = authStorageService,
       _localStore = localStore;

  final CreateShopRepository _repository;
  final AuthStorageService _authStorageService;
  final OwnerShopLocalStore _localStore;

  final Rxn<CreateShopResponseModel> ownerShop = Rxn<CreateShopResponseModel>();
  final RxBool isSubmitting = false.obs;
  final RxBool isLoading = false.obs;

  String _userId = '';

  static const List<String> dayKeys = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    if (isLoading.value) return;

    isLoading.value = true;
    await _loadUserId();

    final CreateShopResponseModel? cachedShop = await _localStore.getShop();
    ownerShop.value = cachedShop;

    if (_userId.isNotEmpty) {
      await _refreshShopFromApi();
    }

    isLoading.value = false;
  }

  Future<void> _refreshShopFromApi() async {
    final result = await _repository.fetchShopsByUserId(userId: _userId);

    CreateShopResponseModel? fetchedShop;
    bool apiSucceeded = false;

    result.fold(
      (failure) {
        if (ownerShop.value == null) {
          _showError('Error', failure.message);
        }
      },
      (success) {
        apiSucceeded = true;
        fetchedShop = success.data.isNotEmpty ? success.data.first : null;
      },
    );

    if (fetchedShop != null) {
      ownerShop.value = fetchedShop;
      await _localStore.saveShop(fetchedShop!);
    } else if (apiSucceeded) {
      ownerShop.value = null;
      await _localStore.clearShop();
    }
  }

  Future<void> _loadUserId() async {
    _userId = (await _authStorageService.getUserId() ?? '').trim();
  }

  bool get hasShop {
    final CreateShopResponseModel? shop = ownerShop.value;
    if (shop == null) return false;
    return shop.shopId.trim().isNotEmpty;
  }

  Future<void> refreshShop() async {
    if (_userId.isEmpty) {
      await _loadUserId();
    }

    if (_userId.isEmpty) return;

    await _refreshShopFromApi();
  }

  Map<String, ShopDayFormValue> getInitialOperatingHours() {
    final Map<String, ShopDayFormValue> mapped = <String, ShopDayFormValue>{};
    final Map<String, CreateShopOperatingDayModel> existing =
        ownerShop.value?.operatingHours ??
        <String, CreateShopOperatingDayModel>{};

    for (final String day in dayKeys) {
      final CreateShopOperatingDayModel? slot = existing[day];
      mapped[day] = ShopDayFormValue(
        open: slot?.open ?? '',
        close: slot?.close ?? '',
        closed: slot?.closed ?? false,
      );
    }

    return mapped;
  }

  Future<bool> submitShop({
    required String restaurantName,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required Map<String, ShopDayFormValue> operatingHours,
    String? imagePath,
  }) async {
    if (isSubmitting.value) return false;

    if (_userId.isEmpty) {
      await _loadUserId();
    }

    if (_userId.isEmpty) {
      _showError('Error', 'Unable to find user id. Please login again.');
      return false;
    }

    final bool isCreate = !hasShop;

    if (isCreate && (imagePath == null || imagePath.trim().isEmpty)) {
      _showError('Validation', 'Please add a shop photo.');
      return false;
    }

    final Map<String, CreateShopOperatingDayRequestModel> requestHours =
        <String, CreateShopOperatingDayRequestModel>{};

    for (final String day in dayKeys) {
      final ShopDayFormValue value =
          operatingHours[day] ??
          const ShopDayFormValue(open: '', close: '', closed: false);
      requestHours[day] = CreateShopOperatingDayRequestModel(
        open: value.open,
        close: value.close,
        closed: value.closed,
      );
    }

    final CreateShopRequestModel request = CreateShopRequestModel(
      userId: _userId,
      restaurantName: restaurantName,
      description: description,
      imagePath: imagePath,
      address: address,
      longitude: longitude,
      latitude: latitude,
      operatingHours: requestHours,
    );

    isSubmitting.value = true;

    final result = isCreate
        ? await _repository.createShop(request: request)
        : await _repository.updateShop(
            shopId: ownerShop.value!.shopId,
            request: request,
          );

    var succeeded = false;

    result.fold(
      (failure) {
        _showError(
          isCreate ? 'Create Failed' : 'Update Failed',
          failure.message,
        );
      },
      (success) {
        ownerShop.value = success.data;
        _localStore.saveShop(success.data);
        succeeded = true;

        Get.snackbar(
          'Success',
          success.message.isNotEmpty
              ? success.message
              : isCreate
              ? 'Shop created successfully'
              : 'Shop updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      },
    );

    isSubmitting.value = false;
    return succeeded;
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }
}
