import 'package:get/get.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/widgets/bottomNavbar/screens/dashboard_screen.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/network/services/onboarding_store_service.dart';
import '../screens/logIn_screen.dart';
import '../screens/role_selection_screen.dart';

enum AppUserRole { user, restaurantOwner }

extension AppUserRoleX on AppUserRole {
  bool get isUser => this == AppUserRole.user;
  bool get isOwner => this == AppUserRole.restaurantOwner;

  String get title => isUser ? 'User' : 'Restaurant Owner';
  String get storageValue => isUser ? 'user' : 'restaurant_owner';
}

AppUserRole roleFromStorage(String? raw) {
  if (raw == AppUserRole.restaurantOwner.storageValue || raw == 'owner') {
    return AppUserRole.restaurantOwner;
  }
  return AppUserRole.user;
}

AuthFlowController ensureAuthFlowController() {
  if (!Get.isRegistered<AuthStorageService>()) {
    Get.lazyPut<AuthStorageService>(() => AuthStorageService(), fenix: true);
  }
  if (!Get.isRegistered<OnboardingStoreService>()) {
    Get.lazyPut<OnboardingStoreService>(
      () => OnboardingStoreService(),
      fenix: true,
    );
  }
  if (!Get.isRegistered<AuthFlowController>()) {
    Get.lazyPut<AuthFlowController>(
      () => AuthFlowController(
        Get.find<AuthStorageService>(),
        Get.find<OnboardingStoreService>(),
      ),
      fenix: true,
    );
  }
  return Get.find<AuthFlowController>();
}

class AuthFlowController extends GetxController {
  AuthFlowController(this._authStorageService, this._onboardingStoreService);

  final AuthStorageService _authStorageService;
  final OnboardingStoreService _onboardingStoreService;

  final selectedRole = Rxn<AppUserRole>();
  final isSubmitting = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadStoredRole();
  }

  Future<void> loadStoredRole() async {
    final storedRole = await _authStorageService.getRole();
    if (storedRole != null && storedRole.isNotEmpty) {
      selectedRole.value = roleFromStorage(storedRole);
    }
  }

  void selectRole(AppUserRole role) {
    selectedRole.value = role;
  }

  Future<void> continueFromRoleSelection() async {
    final role = selectedRole.value;
    if (role == null) {
      Get.snackbar(
        'Role Required',
        'Please select one role to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.white,
      );
      return;
    }

    try {
      await _authStorageService.storeRole(role.storageValue);
    } catch (_) {}
    Get.to(() => const LoginRoleScreen());
  }

  Future<void> finishOnboarding() async {
    try {
      await _onboardingStoreService.storeOnboardingData(isCompleted: 'true');
    } catch (_) {}
    Get.offAll(() => const RoleSelectionScreen());
  }

  Future<void> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        'Missing Fields',
        'Please provide email and password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.white,
      );
      return;
    }

    isSubmitting.value = true;

    var role = selectedRole.value ?? _inferRoleFromEmail(email);
    try {
      final persistedRole = await _authStorageService.getRole();
      if (persistedRole != null && persistedRole.isNotEmpty) {
        role = roleFromStorage(persistedRole);
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 350));
    try {
      await _authStorageService.storeRole(role.storageValue);
      await _authStorageService.storeAccessToken('local_access_token');
      await _authStorageService.storeRefreshToken('local_refresh_token');
      await _authStorageService.storeUserId('local_user');
    } catch (_) {}

    isSubmitting.value = false;
    Get.offAll(() => DashboardScreen(role: role));
  }

  Future<void> createAccount({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required AppUserRole role,
  }) async {
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      Get.snackbar(
        'Missing Fields',
        'Please fill in all fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Password Mismatch',
        'Password and confirm password must match.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.white,
      );
      return;
    }

    isSubmitting.value = true;

    await Future.delayed(const Duration(milliseconds: 350));
    try {
      await _authStorageService.storeRole(role.storageValue);
      await _authStorageService.storeAccessToken('local_access_token');
      await _authStorageService.storeRefreshToken('local_refresh_token');
      await _authStorageService.storeUserId('local_user');
    } catch (_) {}

    isSubmitting.value = false;
    Get.offAll(() => DashboardScreen(role: role));
  }

  Future<void> submitForgotPasswordEmail(String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar(
        'Email Required',
        'Please enter your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.white,
      );
      return;
    }
  }

  Future<void> resetPassword({
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    if (otp.length != 6 || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Invalid Data',
        'Please complete OTP and password fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Password Mismatch',
        'Password and confirm password must match.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.white,
      );
      return;
    }

    Get.offAll(() => const LoginRoleScreen());
  }

  Future<void> logout() async {
    await _authStorageService.clearAuthData();
    Get.offAll(() => const LoginRoleScreen());
  }

  AppUserRole _inferRoleFromEmail(String email) {
    final value = email.toLowerCase();
    if (value.contains('owner') || value.contains('restaurant')) {
      return AppUserRole.restaurantOwner;
    }
    return AppUserRole.user;
  }
}
