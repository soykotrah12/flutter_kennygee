import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
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
      () => ProfileController(Get.find<ProfileRepository>()),
      fenix: true,
    );
  }

  return Get.find<ProfileController>();
}

class ProfileController extends GetxController {
  ProfileController(this._profileRepository);

  final ProfileRepository _profileRepository;
  final ImagePicker _imagePicker = ImagePicker();

  final profile = Rxn<UserProfileModel>();
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
}
