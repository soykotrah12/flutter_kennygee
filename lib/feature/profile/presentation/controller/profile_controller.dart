import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_app/restart_app.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/services/auth_storage_service.dart';
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
  if (!Get.isRegistered<ProfileController>()) {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileRepository>(),
        Get.find<ApiClient>(),
        Get.find<StripeConnectRepository>(),
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
  );

  final ProfileRepository _profileRepository;
  final ApiClient _apiClient;
  final StripeConnectRepository _stripeConnectRepository;
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
  CancelToken? _profileCancelToken;
  CancelToken? _wishlistCountCancelToken;
  CancelToken? _bookmarkCountCancelToken;
  CancelToken? _stripeStatusCancelToken;

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
    if (_shouldSkipForAccountDeletion) return;

    _fetchProfileCount++;
    debugPrint('[ProfileController] fetchProfile #$_fetchProfileCount');
    if (showLoader) {
      isProfileLoading.value = true;
    }

    final cancelToken = CancelToken();
    _profileCancelToken = cancelToken;
    final result = await _profileRepository.getProfile(
      cancelToken: cancelToken,
    );
    if (identical(_profileCancelToken, cancelToken)) {
      _profileCancelToken = null;
    }
    if (_shouldIgnoreAccountDeletionResult) {
      if (showLoader) {
        isProfileLoading.value = false;
      }
      return;
    }

    result.fold(
      (failure) {
        _showError('Profile', failure.message);
      },
      (success) {
        if (_shouldIgnoreAccountDeletionResult) return;
        profile.value = success.data;
        nameController.text = success.data.name;
      },
    );

    if (showLoader) {
      isProfileLoading.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    if (_shouldSkipForAccountDeletion) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) return;
    selectedImagePath.value = pickedImage.path;
  }

  Future<void> updateProfile() async {
    if (isSaving.value || _shouldSkipForAccountDeletion) return;

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
        if (_shouldIgnoreAccountDeletionResult) return;
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
    if (isChangingPassword.value || _shouldSkipForAccountDeletion) return;

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
        if (_shouldIgnoreAccountDeletionResult) return;
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

    final passwordController = TextEditingController();
    var obscurePassword = true;
    String? passwordError;

    await Get.dialog<void>(
      Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Obx(() {
                final isSubmitting = isDeletingAccount.value;

                return AlertDialog(
                  backgroundColor: AppColors.cardColor(context),
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
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please enter your password to permanently delete your account. This action cannot be undone.',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        enabled: !isSubmitting,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: passwordError,
                          filled: true,
                          fillColor: AppColors.inputFill(context),
                          labelStyle: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontFamily: 'Montserrat',
                          ),
                          errorStyle: const TextStyle(fontFamily: 'Montserrat'),
                          suffixIcon: IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    setDialogState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.divider(context),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 1.2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.red),
                          ),
                        ),
                        onChanged: (value) {
                          if (passwordError == null || value.trim().isEmpty) {
                            return;
                          }
                          setDialogState(() {
                            passwordError = null;
                          });
                        },
                      ),
                    ],
                  ),
                  actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                  actions: [
                    TextButton(
                      onPressed: isSubmitting ? null : () => Get.back<void>(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondaryText(context),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final password = passwordController.text.trim();
                              if (password.isEmpty) {
                                setDialogState(() {
                                  passwordError = 'Password is required.';
                                });
                                return;
                              }

                              setDialogState(() {
                                passwordError = null;
                              });
                              await deleteAccount(password: password);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.red.withValues(
                          alpha: 0.55,
                        ),
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Delete Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                    ),
                  ],
                );
              });
            },
          );
        },
      ),
      barrierDismissible: false,
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        passwordController.dispose();
      });
    });
  }

  Future<void> deleteAccount({required String password}) async {
    if (isDeletingAccount.value) return;

    final trimmedPassword = password.trim();
    if (trimmedPassword.isEmpty) {
      _showError('Validation', 'Password is required.');
      return;
    }

    isDeletingAccount.value = true;
    final result = await _profileRepository.deleteAccount(
      password: trimmedPassword,
    );

    await result.fold<Future<void>>(
      (failure) async {
        isDeletingAccount.value = false;
        _showError(
          'Delete Account',
          _cleanDeleteAccountErrorMessage(failure.message, failure.statusCode),
        );
      },
      (success) async {
        AuthStorageService.isAccountDeleting = true;
        FocusManager.instance.primaryFocus?.unfocus();

        if (Get.isDialogOpen == true) {
          Get.back<void>();
        }

        _showSuccess('Account deleted successfully');

        await AuthStorageService().clearSessionSilently(
          reason: 'account_deleted',
        );

        await Future<void>.delayed(const Duration(milliseconds: 300));

        await Restart.restartApp();
      },
    );
  }

  void _cancelAccountDeletionSensitiveRequests() {
    _profileCancelToken?.cancel('Account deleted');
    _wishlistCountCancelToken?.cancel('Account deleted');
    _bookmarkCountCancelToken?.cancel('Account deleted');
    _stripeStatusCancelToken?.cancel('Account deleted');
    _profileCancelToken = null;
    _wishlistCountCancelToken = null;
    _bookmarkCountCancelToken = null;
    _stripeStatusCancelToken = null;
  }

  Future<void> fetchQuickAccessCounts() async {
    if (_shouldSkipForAccountDeletion) return;

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
    if (_shouldSkipForAccountDeletion) return;

    if (showLoader) {
      isStripeStatusLoading.value = true;
    }
    try {
      final cancelToken = CancelToken();
      _stripeStatusCancelToken = cancelToken;
      final result = await _stripeConnectRepository.fetchStatus(
        cancelToken: cancelToken,
      );
      if (identical(_stripeStatusCancelToken, cancelToken)) {
        _stripeStatusCancelToken = null;
      }
      if (_shouldIgnoreAccountDeletionResult) {
        return;
      }
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
    if (isStripeOnboardingLoading.value || _shouldSkipForAccountDeletion) {
      return;
    }

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
    if (_shouldSkipForAccountDeletion) return;

    final cancelToken = CancelToken();
    _wishlistCountCancelToken = cancelToken;
    final result = await _apiClient.get<int>(
      ApiConstants.wishlist.fetchMyWishlist,
      cancelToken: cancelToken,
      fromJsonT: _extractWishlistCount,
    );
    if (identical(_wishlistCountCancelToken, cancelToken)) {
      _wishlistCountCancelToken = null;
    }
    if (_shouldIgnoreAccountDeletionResult) return;

    result.fold((_) => totalWishlist.value = 0, (success) {
      totalWishlist.value = success.data;
    });
  }

  Future<void> _fetchBookmarkCount() async {
    if (_shouldSkipForAccountDeletion) return;

    final cancelToken = CancelToken();
    _bookmarkCountCancelToken = cancelToken;
    final result = await _apiClient.get<int>(
      ApiConstants.bookmark.fetchMyBookmarks,
      cancelToken: cancelToken,
      fromJsonT: _extractBookmarkCount,
    );
    if (identical(_bookmarkCountCancelToken, cancelToken)) {
      _bookmarkCountCancelToken = null;
    }
    if (_shouldIgnoreAccountDeletionResult) return;

    result.fold((_) => totalBookmarks.value = 0, (success) {
      totalBookmarks.value = success.data;
    });
  }

  @override
  void onClose() {
    _cancelAccountDeletionSensitiveRequests();
    nameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  void _showError(String title, String message) {
    if (_shouldSkipForAccountDeletion) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.cardAdaptive,
    );
  }

  bool get _shouldIgnoreAccountDeletionResult =>
      _shouldSkipForAccountDeletion || isClosed;

  bool get _shouldSkipForAccountDeletion =>
      AuthStorageService.isClearingAfterAccountDelete || isClosed;

  String _cleanDeleteAccountErrorMessage(String message, int statusCode) {
    final String trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return 'Unable to delete account right now. Please try again.';
    }
    if (trimmed.toLowerCase() == 'api not found' && statusCode != 404) {
      return 'Unable to delete account right now. Please try again.';
    }
    return trimmed;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryGreen,
      colorText: Colors.white,
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
