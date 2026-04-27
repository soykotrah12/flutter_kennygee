import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/update_menu_request_model.dart';
import '../../data/model/update_menu_response_model.dart';
import '../../data/repo/home_food_repo.dart';

OwnerMenuUpdateController ensureOwnerMenuUpdateController({
  required String menuId,
  required UpdateMenuResponseModel menuData,
}) {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<HomeFoodRepository>()) {
    Get.lazyPut<HomeFoodRepository>(
      () => HomeFoodRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  final String tag = 'menu_update_$menuId';

  if (!Get.isRegistered<OwnerMenuUpdateController>(tag: tag)) {
    Get.put<OwnerMenuUpdateController>(
      OwnerMenuUpdateController(
        menuId: menuId,
        menuData: menuData,
        repository: Get.find<HomeFoodRepository>(),
      ),
      tag: tag,
    );
  }

  return Get.find<OwnerMenuUpdateController>(tag: tag);
}

class OwnerMenuUpdateController extends GetxController {
  OwnerMenuUpdateController({
    required String menuId,
    required UpdateMenuResponseModel menuData,
    required HomeFoodRepository repository,
  })  : _menuId = menuId,
        _menuData = menuData,
        _repository = repository;

  final String _menuId;
  final UpdateMenuResponseModel _menuData;
  final HomeFoodRepository _repository;

  final RxBool isSubmitting = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isTogglingOffer = false.obs;

  String get dishName => _menuData.dishName;
  String get description => _menuData.description;
  String get category => _menuData.category;
  double get basePrice => _menuData.basePrice;
  bool get specialOffer => _menuData.specialOffer;
  String get offerText => _menuData.offerText;
  List<String> get imageUrls =>
      _menuData.images.map((img) => img.url).toList();

  Future<bool> submitUpdate({
    required String dishName,
    required String description,
    required String category,
    required double basePrice,
    required bool specialOffer,
    required String offerText,
    String? imagePath,
  }) async {
    if (isSubmitting.value) return false;

    final UpdateMenuRequestModel request = UpdateMenuRequestModel(
      dishName: dishName,
      description: description,
      category: category,
      basePrice: basePrice,
      specialOffer: specialOffer,
      offerText: offerText,
      imagePath: imagePath,
    );

    isSubmitting.value = true;

    final result = await _repository.updateMenu(
      menuId: _menuId,
      request: request,
    );

    var succeeded = false;

    result.fold(
      (failure) {
        _showError('Update Failed', failure.message);
      },
      (success) {
        succeeded = true;
        Get.snackbar(
          'Success',
          'Menu item updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back(result: true);
        });
      },
    );

    isSubmitting.value = false;
    return succeeded;
  }

  Future<void> deleteMenu() async {
    if (isDeleting.value) return;

    final bool? confirmDelete = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Menu Item?',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This action cannot be undone. This menu item will be permanently deleted.',
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    isDeleting.value = true;

    final result = await _repository.deleteMenu(menuId: _menuId);

    result.fold(
      (failure) {
        _showError('Delete Failed', failure.message);
      },
      (success) {
        Get.snackbar(
          'Success',
          'Menu item deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back(result: 'deleted');
        });
      },
    );

    isDeleting.value = false;
  }

  Future<void> toggleSpecialOffer() async {
    if (isTogglingOffer.value) return;

    isTogglingOffer.value = true;

    final result = await _repository.toggleSpecialOffer(menuId: _menuId);

    result.fold(
      (failure) {
        _showError('Toggle Failed', failure.message);
      },
      (success) {
        final message = specialOffer
            ? 'Special offer disabled'
            : 'Special offer enabled';
        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      },
    );

    isTogglingOffer.value = false;
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
