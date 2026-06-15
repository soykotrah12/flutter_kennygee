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

  ShopDayFormValue copyWith({String? open, String? close, bool? closed}) {
    return ShopDayFormValue(
      open: open ?? this.open,
      close: close ?? this.close,
      closed: closed ?? this.closed,
    );
  }
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
  final RxMap<String, ShopDayFormValue> operatingHoursState =
      <String, ShopDayFormValue>{}.obs;

  String _userId = '';
  bool _operatingHoursTouched = false;

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
    if (_isAccountDeleting) return;
    initialize();
  }

  Future<void> initialize() async {
    if (isLoading.value || _isAccountDeleting || isClosed) return;

    isLoading.value = true;
    await _loadUserId();
    if (_isAccountDeleting || isClosed) return;

    final CreateShopResponseModel? cachedShop = await _localStore.getShop();
    if (_isAccountDeleting || isClosed) return;
    ownerShop.value = cachedShop;
    _resetOperatingHoursFromMap(cachedShop?.operatingHours);

    if (_userId.isNotEmpty) {
      await _refreshShopFromApi();
    }

    if (!_isAccountDeleting && !isClosed) {
      isLoading.value = false;
    }
  }

  Future<void> _refreshShopFromApi() async {
    if (_isAccountDeleting || isClosed) return;

    final result = await _repository.fetchShopsByUserId(userId: _userId);
    if (_isAccountDeleting || isClosed) return;

    CreateShopResponseModel? fetchedShop;
    bool apiSucceeded = false;

    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        if (ownerShop.value == null) {
          _showError('Error', failure.message);
        }
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        apiSucceeded = true;
        fetchedShop = success.data.isNotEmpty ? success.data.first : null;
      },
    );

    if (fetchedShop != null) {
      ownerShop.value = fetchedShop;
      _resetOperatingHoursFromMap(fetchedShop!.operatingHours);
      await _localStore.saveShop(fetchedShop!);
    } else if (apiSucceeded) {
      ownerShop.value = null;
      _resetOperatingHoursFromMap(null, force: true);
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
    if (_isAccountDeleting || isClosed) return;

    if (_userId.isEmpty) {
      await _loadUserId();
    }

    if (_userId.isEmpty) return;

    await _refreshShopFromApi();
  }

  void resetOperatingHoursFromShop({bool force = false}) {
    _resetOperatingHoursFromMap(ownerShop.value?.operatingHours, force: force);
  }

  Map<String, ShopDayFormValue> getInitialOperatingHours() {
    if (operatingHoursState.isEmpty) {
      resetOperatingHoursFromShop();
    }

    return Map<String, ShopDayFormValue>.from(operatingHoursState);
  }

  ShopDayFormValue getDayValue(String day) {
    final String key = _normalizeDayKey(day);
    return operatingHoursState[key] ??
        const ShopDayFormValue(open: '', close: '', closed: false);
  }

  bool isDayClosed(String day) => getDayValue(day).closed;

  String getDayOpenLabel(String day) {
    final ShopDayFormValue value = getDayValue(day);
    final String open = value.open.trim();
    if (value.closed) return 'N/A';
    return open.isNotEmpty ? open : 'N/A';
  }

  String getDayCloseLabel(String day) {
    final ShopDayFormValue value = getDayValue(day);
    final String close = value.close.trim();
    if (value.closed) return 'N/A';
    return close.isNotEmpty ? close : 'N/A';
  }

  String getDayDisplayText(String day) {
    final ShopDayFormValue value = getDayValue(day);
    if (value.closed) return 'Closed';

    final String open = value.open.trim();
    final String close = value.close.trim();
    final String openLabel = open.isNotEmpty ? open : 'N/A';
    final String closeLabel = close.isNotEmpty ? close : 'N/A';
    return '$openLabel - $closeLabel';
  }

  void toggleDayClosed(String day) {
    toggleClosed(day);
  }

  void toggleClosed(String day) {
    final String key = _normalizeDayKey(day);
    final ShopDayFormValue current = getDayValue(key);
    if (current.closed) {
      _setDayValue(key, current.copyWith(closed: false));
      return;
    }
    _setDayValue(
      key,
      const ShopDayFormValue(open: '', close: '', closed: true),
    );
  }

  void updateDayOpenTime(String day, String time) {
    setOpenTime(day, time);
  }

  void setOpenTime(String day, String time) {
    final String key = _normalizeDayKey(day);
    final ShopDayFormValue current = getDayValue(key);
    _setDayValue(key, current.copyWith(open: time.trim(), closed: false));
  }

  void updateDayCloseTime(String day, String time) {
    setCloseTime(day, time);
  }

  void setCloseTime(String day, String time) {
    final String key = _normalizeDayKey(day);
    final ShopDayFormValue current = getDayValue(key);
    _setDayValue(key, current.copyWith(close: time.trim(), closed: false));
  }

  void markDayClosed(String day) {
    final String key = _normalizeDayKey(day);
    _setDayValue(
      key,
      const ShopDayFormValue(open: '', close: '', closed: true),
    );
  }

  Map<String, ShopDayFormValue> getOperatingHoursForPayload() {
    final Map<String, ShopDayFormValue> mapped = <String, ShopDayFormValue>{};

    for (final String day in dayKeys) {
      final ShopDayFormValue value = getDayValue(day);
      final bool isClosed = value.closed;
      mapped[day] = ShopDayFormValue(
        open: isClosed ? '' : value.open.trim(),
        close: isClosed ? '' : value.close.trim(),
        closed: isClosed,
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
    Map<String, ShopDayFormValue>? operatingHours,
    String? imagePath,
  }) async {
    if (isSubmitting.value || _isAccountDeleting || isClosed) return false;

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
    final Map<String, ShopDayFormValue> sourceHours =
        operatingHours ?? getOperatingHoursForPayload();

    for (final String day in dayKeys) {
      final ShopDayFormValue value =
          sourceHours[day] ??
          const ShopDayFormValue(open: '', close: '', closed: false);
      final bool isClosed = value.closed;
      requestHours[day] = CreateShopOperatingDayRequestModel(
        open: isClosed ? '' : value.open,
        close: isClosed ? '' : value.close,
        closed: isClosed,
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

    if (_isAccountDeleting || isClosed) return false;
    var succeeded = false;

    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        _showError(
          isCreate ? 'Create Failed' : 'Update Failed',
          failure.message,
        );
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
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

    if (!_isAccountDeleting && !isClosed) {
      isSubmitting.value = false;
    }
    return succeeded;
  }

  void _showError(String title, String message) {
    if (_isAccountDeleting || isClosed) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.cardAdaptive,
      margin: const EdgeInsets.all(12),
    );
  }

  void _resetOperatingHoursFromMap(
    Map<String, CreateShopOperatingDayModel>? existing, {
    bool force = false,
  }) {
    if (_operatingHoursTouched && !force) return;

    final Map<String, ShopDayFormValue> mapped = <String, ShopDayFormValue>{};
    final Map<String, CreateShopOperatingDayModel> safe =
        existing ?? <String, CreateShopOperatingDayModel>{};

    for (final String day in dayKeys) {
      final CreateShopOperatingDayModel? slot = safe[day];
      mapped[day] = ShopDayFormValue(
        open: (slot?.open ?? '').trim(),
        close: (slot?.close ?? '').trim(),
        closed: slot?.closed ?? false,
      );
    }

    operatingHoursState.assignAll(mapped);
    _operatingHoursTouched = false;
  }

  void _setDayValue(String day, ShopDayFormValue value) {
    final String key = _normalizeDayKey(day);
    operatingHoursState[key] = value;
    operatingHoursState.refresh();
    _operatingHoursTouched = true;
  }

  String _normalizeDayKey(String day) {
    final String normalized = day.trim().toLowerCase();
    if (dayKeys.contains(normalized)) return normalized;
    return dayKeys.first;
  }

  bool get _isAccountDeleting =>
      AuthStorageService.isClearingAfterAccountDelete;
}
