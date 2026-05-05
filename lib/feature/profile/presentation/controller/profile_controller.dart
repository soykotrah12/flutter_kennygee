import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/user_profile_model.dart';
import '../../data/repo/profile_repo_impl.dart';
import '../../domain/repo/profile_repo.dart';

ProfileController ensureProfileController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<ProfileRepository>()) {
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<ProfileController>()) {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileRepository>(),
        Get.find<ApiClient>(),
      ),
      fenix: true,
    );
  }

  return Get.find<ProfileController>();
}

class ProfileController extends GetxController {
  ProfileController(this._profileRepository, this._apiClient);

  final ProfileRepository _profileRepository;
  final ApiClient _apiClient;
  final ImagePicker _imagePicker = ImagePicker();

  final profile = Rxn<UserProfileModel>();
  final RxInt totalWishlist = 0.obs;
  final RxInt totalBookmarks = 0.obs;
  final isProfileLoading = false.obs;
  final isSaving = false.obs;
  final isChangingPassword = false.obs;
  final selectedImagePath = RxnString();
  final nameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchQuickAccessCounts();
  }

  Future<void> fetchProfile({bool showLoader = true}) async {
    if (showLoader) {
      isProfileLoading.value = true;
    }

    final result = await _profileRepository.getProfile();

    result.fold(
      (failure) {
        _showError('Profile', failure.message);
      },
      (success) {
        profile.value = success.data;
        nameController.text = success.data.name;
      },
    );

    if (showLoader) {
      isProfileLoading.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) return;
    selectedImagePath.value = pickedImage.path;
  }

  Future<void> updateProfile() async {
    if (isSaving.value) return;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      _showError('Validation', 'Name is required.');
      return;
    }

    isSaving.value = true;

    final result = await _profileRepository.updateProfile(
      name: name,
      profileImagePath: selectedImagePath.value,
    );

    result.fold(
      (failure) {
        _showError('Update Failed', failure.message);
      },
      (success) {
        profile.value = success.data;
        nameController.text = success.data.name;
        selectedImagePath.value = null;
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        }
        Future.delayed(const Duration(milliseconds: 120), () {
          Get.snackbar(
            'Success',
            success.message.isNotEmpty
                ? success.message
                : 'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primaryGreen,
            colorText: Colors.white,
          );
        });
      },
    );

    isSaving.value = false;
  }

  Future<void> changePassword() async {
    if (isChangingPassword.value) return;

    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmNewPassword = confirmNewPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmNewPassword.isEmpty) {
      _showError('Validation', 'Please fill in all password fields.');
      return;
    }

    if (newPassword != confirmNewPassword) {
      _showError('Validation', 'New password and confirm password must match.');
      return;
    }

    isChangingPassword.value = true;

    final result = await _profileRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    result.fold(
      (failure) {
        _showError('Update Failed', failure.message);
      },
      (success) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();

        Get.back();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Success',
            success.message.isNotEmpty
                ? success.message
                : 'Password updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primaryGreen,
            colorText: Colors.white,
          );
        });
      },
    );

    isChangingPassword.value = false;
  }

  Future<void> fetchQuickAccessCounts() async {
    await Future.wait<void>(<Future<void>>[
      _fetchWishlistCount(),
      _fetchBookmarkCount(),
    ]);
  }

  Future<void> _fetchWishlistCount() async {
    final result = await _apiClient.get<int>(
      ApiConstants.wishlist.fetchMyWishlist,
      fromJsonT: _extractWishlistCount,
    );

    result.fold((_) => totalWishlist.value = 0, (success) {
      totalWishlist.value = success.data;
    });
  }

  Future<void> _fetchBookmarkCount() async {
    final result = await _apiClient.get<int>(
      ApiConstants.bookmark.fetchMyBookmarks,
      fromJsonT: _extractBookmarkCount,
    );

    result.fold((_) => totalBookmarks.value = 0, (success) {
      totalBookmarks.value = success.data;
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return <dynamic>[];
  }

  int _extractWishlistCount(dynamic json) {
    final Map<String, dynamic> payload = _asMap(json);
    final int directCount = _asInt(payload['totalWishlist']);
    if (directCount > 0 || payload.containsKey('totalWishlist')) {
      return directCount;
    }

    final Map<String, dynamic> nested = _asMap(payload['data']);
    final int nestedCount = _asInt(nested['totalWishlist']);
    if (nestedCount > 0 || nested.containsKey('totalWishlist')) {
      return nestedCount;
    }

    final int shops = _asList(payload['shopItems']).length;
    final int menus = _asList(payload['menuItems']).length;
    if (shops + menus > 0) {
      return shops + menus;
    }

    final int nestedShops = _asList(nested['shopItems']).length;
    final int nestedMenus = _asList(nested['menuItems']).length;
    return nestedShops + nestedMenus;
  }

  int _extractBookmarkCount(dynamic json) {
    final Map<String, dynamic> payload = _asMap(json);
    final int directCount = _asInt(payload['totalBookmarks']);
    if (directCount > 0 || payload.containsKey('totalBookmarks')) {
      return directCount;
    }

    final Map<String, dynamic> nested = _asMap(payload['data']);
    final int nestedCount = _asInt(nested['totalBookmarks']);
    if (nestedCount > 0 || nested.containsKey('totalBookmarks')) {
      return nestedCount;
    }

    final int directListCount = _asList(payload['bookmarks']).length;
    if (directListCount > 0 || payload.containsKey('bookmarks')) {
      return directListCount;
    }

    return _asList(nested['bookmarks']).length;
  }
}
