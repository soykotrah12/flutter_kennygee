import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';
import '../../../auth/presentation/screens/logIn_screen.dart';
import '../../data/model/user_profile_model.dart';
import '../../data/repo/profile_repo_impl.dart';
import '../../data/repo/stripe_connect_repository.dart';
import '../../domain/repo/profile_repo.dart';
import '../screens/stripe_onboarding_webview_screen.dart';

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

  if (!Get.isRegistered<StripeConnectRepository>()) {
    Get.lazyPut<StripeConnectRepository>(
      () => StripeConnectRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }
  if (!Get.isRegistered<AuthStorageService>()) {
    Get.lazyPut<AuthStorageService>(() => AuthStorageService(), fenix: true);
  }

  if (!Get.isRegistered<ProfileController>()) {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileRepository>(),
        Get.find<ApiClient>(),
        Get.find<StripeConnectRepository>(),
        Get.find<AuthStorageService>(),
      ),
      fenix: true,
    );
  }

  return Get.find<ProfileController>();
}

class ProfileController extends GetxController {
  ProfileController(
    this._profileRepository,
    this._apiClient,
    this._stripeConnectRepository,
    this._authStorageService,
  );

  final ProfileRepository _profileRepository;
  final ApiClient _apiClient;
  final StripeConnectRepository _stripeConnectRepository;
  final AuthStorageService _authStorageService;
  final ImagePicker _imagePicker = ImagePicker();

  final profile = Rxn<UserProfileModel>();
  final RxInt totalWishlist = 0.obs;
  final RxInt totalBookmarks = 0.obs;
  final isProfileLoading = false.obs;
  final isSaving = false.obs;
  final isChangingPassword = false.obs;
  final isDeletingAccount = false.obs;
  final stripeConnected = false.obs;
  final stripeAccountId = ''.obs;
  final isStripeStatusLoading = false.obs;
  final isStripeOnboardingLoading = false.obs;
  final selectedImagePath = RxnString();
  final nameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  static int _initCount = 0;
  int _fetchProfileCount = 0;
  int _fetchQuickAccessCount = 0;
  bool _didRequestStripeStatus = false;

  @override
  void onInit() {
    super.onInit();
    _initCount++;
    debugPrint('[ProfileController] onInit count=$_initCount');
    fetchProfile();
    fetchQuickAccessCounts();
  }

  void onOwnerProfileOpened() {
    if (_didRequestStripeStatus) return;
    _didRequestStripeStatus = true;
    fetchStripeConnectStatus();
  }

  Future<void> fetchProfile({bool showLoader = true}) async {
    _fetchProfileCount++;
    debugPrint('[ProfileController] fetchProfile #$_fetchProfileCount');
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

  Future<void> confirmDeleteAccount() async {
    if (isDeletingAccount.value) return;

    final bool? shouldDelete = await Get.dialog<bool>(
      Builder(
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.cardAdaptive,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              'Delete Account',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            content: Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back<bool>(result: false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back<bool>(result: true),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (shouldDelete == true) {
      await deleteAccount();
    }
  }

  Future<void> deleteAccount() async {
    if (isDeletingAccount.value) return;

    isDeletingAccount.value = true;
    final result = await _profileRepository.deleteAccount();

    await result.fold<Future<void>>(
      (failure) async {
        isDeletingAccount.value = false;
        _showError('Delete Account', _cleanErrorMessage(failure.message));
      },
      (success) async {
        await _authStorageService.clearAuthData();
        await ensureAuthFlowController().exitGuestMode();
        profile.value = null;
        totalWishlist.value = 0;
        totalBookmarks.value = 0;
        isDeletingAccount.value = false;

        Get.offAll(() => const LoginRoleScreen());
        Future<void>.delayed(const Duration(milliseconds: 120), () {
          Get.snackbar(
            'Account Deleted',
            success.message.isNotEmpty
                ? success.message
                : 'Your account has been deleted successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primaryGreen,
            colorText: Colors.white,
          );
        });
      },
    );
  }

  Future<void> fetchQuickAccessCounts() async {
    _fetchQuickAccessCount++;
    debugPrint(
      '[ProfileController] fetchQuickAccessCounts #$_fetchQuickAccessCount',
    );
    await Future.wait<void>(<Future<void>>[
      _fetchWishlistCount(),
      _fetchBookmarkCount(),
    ]);
  }

  Future<void> fetchStripeConnectStatus({bool showLoader = true}) async {
    if (showLoader) {
      isStripeStatusLoading.value = true;
    }
    try {
      final result = await _stripeConnectRepository.fetchStatus();
      result.fold(
        (_) {
          stripeConnected.value = false;
          stripeAccountId.value = '';
        },
        (success) {
          stripeConnected.value = success.data.connected;
          stripeAccountId.value = success.data.accountId;
        },
      );
    } finally {
      if (showLoader) {
        isStripeStatusLoading.value = false;
      }
    }
  }

  Future<void> onTapStripeConnect() async {
    if (isStripeOnboardingLoading.value) return;

    if (stripeConnected.value) {
      Get.snackbar(
        'Stripe Connect',
        'Stripe already connected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.cardAdaptive,
      );
      return;
    }

    isStripeOnboardingLoading.value = true;
    try {
      final result = await _stripeConnectRepository.createOnboardingLink();
      await result.fold(
        (failure) async {
          _showError('Stripe Connect', failure.message);
        },
        (success) async {
          final onboardingUrl = success.data.onboardingUrl.trim();
          if (onboardingUrl.isEmpty) {
            _showError(
              'Stripe Connect',
              'Unable to start onboarding right now. Please try again.',
            );
            return;
          }

          await Get.to<bool>(
            () => StripeOnboardingWebViewScreen(onboardingUrl: onboardingUrl),
          );
          await fetchStripeConnectStatus();
        },
      );
    } finally {
      isStripeOnboardingLoading.value = false;
    }
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
      backgroundColor: AppColors.cardAdaptive,
    );
  }

  String _cleanErrorMessage(String message) {
    final String trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return 'Unable to delete account right now. Please try again.';
    }
    return trimmed;
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
