import 'package:get/get.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/widgets/bottomNavbar/screens/dashboard_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/network/services/onboarding_store_service.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../../domain/repo/auth_repo.dart';
import '../../data/model/auth_response_model.dart';
import '../../data/model/login_request_model.dart';
import '../../data/model/register_request_model.dart';
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
  final value = raw?.trim().toLowerCase() ?? '';
  if (value == AppUserRole.restaurantOwner.storageValue ||
      value == 'owner' ||
      value == 'restaurant-owner') {
    return AppUserRole.restaurantOwner;
  }
  return AppUserRole.user;
}

AuthFlowController ensureAuthFlowController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }
  if (!Get.isRegistered<AuthRepository>()) {
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }
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
        Get.find<AuthRepository>(),
      ),
      fenix: true,
    );
  }
  return Get.find<AuthFlowController>();
}

class AuthFlowController extends GetxController {
  AuthFlowController(
    this._authStorageService,
    this._onboardingStoreService,
    this._authRepository,
  );

  final AuthStorageService _authStorageService;
  final OnboardingStoreService _onboardingStoreService;
  final AuthRepository _authRepository;

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
    if (isSubmitting.value) return;

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
    try {
      final request = LoginRequestModel(
        email: email.trim(),
        password: password.trim(),
      );
      final result = await _authRepository.login(request);

      await result.fold<Future<void>>(
        (failure) async {
          _showError('Login Failed', failure.message);
        },
        (success) async {
          final role = await _persistAuthSessionAndResolveRole(success.data);
          Get.offAll(() => DashboardScreen(role: role));
        },
      );
    } catch (_) {
      _showError('Login Failed', 'Something went wrong. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required AppUserRole role,
  }) async {
    if (isSubmitting.value) return;

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
    try {
      final request = RegisterRequestModel(
        name: fullName.trim(),
        email: email.trim(),
        phoneNumber: phone.trim(),
        password: password.trim(),
        confirmPassword: confirmPassword.trim(),
        role: role.storageValue,
      );
      final result = await _authRepository.register(request);

      await result.fold<Future<void>>(
        (failure) async {
          _showError('Sign Up Failed', failure.message);
        },
        (success) async {
          final resolvedRole = await _persistAuthSessionAndResolveRole(
            success.data,
            fallbackRole: role,
          );
          Get.offAll(() => DashboardScreen(role: resolvedRole));
        },
      );
    } catch (_) {
      _showError('Sign Up Failed', 'Something went wrong. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> createAccount({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required AppUserRole role,
  }) {
    return signUp(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
    );
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

  Future<void> logoutFromApi() async {
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    try {
      final result = await _authRepository.logout();
      await result.fold<Future<void>>(
        (_) async {
          await _authStorageService.clearAuthData();
          Get.offAll(() => const LoginRoleScreen());
        },
        (_) async {
          await _authStorageService.clearAuthData();
          Get.offAll(() => const LoginRoleScreen());
        },
      );
    } catch (_) {
      await _authStorageService.clearAuthData();
      Get.offAll(() => const LoginRoleScreen());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<AppUserRole> _persistAuthSessionAndResolveRole(
    AuthResponseModel response, {
    AppUserRole? fallbackRole,
  }) async {
    final resolvedRole = _resolveRole(
      response.role.isNotEmpty ? response.role : response.user.role,
      fallbackRole: fallbackRole,
    );
    selectedRole.value = resolvedRole;

    await _authStorageService.clearAuthData();
    if (response.accessToken.isNotEmpty) {
      await _authStorageService.storeAccessToken(response.accessToken);
    }
    if (response.refreshToken.isNotEmpty) {
      await _authStorageService.storeRefreshToken(response.refreshToken);
    }
    await _authStorageService.storeUserId(response.id);
    await _authStorageService.storeRole(resolvedRole.storageValue);

    return resolvedRole;
  }

  AppUserRole _resolveRole(String rawRole, {AppUserRole? fallbackRole}) {
    if (rawRole.trim().isNotEmpty) {
      return roleFromStorage(rawRole);
    }
    if (fallbackRole != null) {
      return fallbackRole;
    }
    return selectedRole.value ?? AppUserRole.user;
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.white,
    );
  }
}
