import 'package:get/get.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/widgets/bottomNavbar/controllers/bottom_nav_controller.dart';
import '../../../../core/common/widgets/bottomNavbar/screens/dashboard_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/network/services/onboarding_store_service.dart';
import '../../../../core/network/models/network_failure.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../Ai/presentation/controllers/ai_chat_controller.dart';
import '../../../home/presentation/controller/home_wishlist_controller.dart';
import '../../../profile/presentation/controller/profile_controller.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../../domain/repo/auth_repo.dart';
import '../../data/model/auth_response_model.dart';
import '../../data/model/login_request_model.dart';
import '../../data/model/refresh_token_request_model.dart';
import '../../data/model/register_request_model.dart';
import '../../data/model/verify_otp_request-model.dart';
import '../screens/OnboardingScreen1.dart';
import '../screens/logIn_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/role_selection_screen.dart';

enum AppUserRole { user, restaurantOwner }

enum OtpVerificationPurpose {
  signupEmailVerification,
  unverifiedLogin,
  unverifiedSignupRetry,
}

extension OtpVerificationPurposeX on OtpVerificationPurpose {
  String get logValue {
    switch (this) {
      case OtpVerificationPurpose.signupEmailVerification:
        return 'signup_email_verification';
      case OtpVerificationPurpose.unverifiedLogin:
        return 'unverified_login';
      case OtpVerificationPurpose.unverifiedSignupRetry:
        return 'unverified_signup_retry';
    }
  }
}

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
  final isGuestMode = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadStoredAuthState();
  }

  Future<void> loadStoredAuthState() async {
    isGuestMode.value = await _authStorageService.isGuestMode();
    await loadStoredRole();
    if (isGuestMode.value) {
      selectedRole.value = AppUserRole.user;
    }
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

  Future<void> startAppFromSplash() async {
    if (AuthStorageService.isClearingAfterAccountDelete) return;

    final accessToken = (await _authStorageService.getAccessToken())?.trim();
    final refreshToken = (await _authStorageService.getRefreshToken())?.trim();
    final storedRole = await _authStorageService.getRole();
    final bool isGuest = await _authStorageService.isGuestMode();
    final bool onboardingCompleted = await _onboardingStoreService
        .isOnboardingCompleted();

    if (accessToken != null && accessToken.isNotEmpty) {
      await _openAuthenticatedDashboard(roleFromStorage(storedRole));
      return;
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      final AppUserRole? refreshedRole = await _tryRestoreSession(
        refreshToken: refreshToken,
        fallbackRole: roleFromStorage(storedRole),
      );
      if (refreshedRole != null) {
        await _openAuthenticatedDashboard(refreshedRole);
        return;
      }
    }

    if (isGuest) {
      await restoreGuestMode();
      Get.offAll(() => DashboardScreen(role: AppUserRole.user));
      return;
    }

    await _authStorageService.clearAuthData();
    selectedRole.value = null;
    isGuestMode.value = false;

    if (!onboardingCompleted) {
      Get.offAll(() => const OnboardingScreen1());
      return;
    }

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
          if (_isUnverifiedEmailFailure(failure)) {
            await _handleUnverifiedEmail(
              email: email.trim(),
              role: selectedRole.value,
              purpose: OtpVerificationPurpose.unverifiedLogin,
            );
            return;
          }
          _showError('Login Failed', _cleanAuthErrorMessage(failure.message));
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
        password.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      Get.snackbar(
        'Missing Fields',
        'Please fill in all required fields.',
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
        phoneNumber: phone.trim().isEmpty ? null : phone.trim(),
        password: password.trim(),
        confirmPassword: confirmPassword.trim(),
        role: role.storageValue,
      );
      final result = await _authRepository.register(request);

      await result.fold<Future<void>>(
        (failure) async {
          if (_isUnverifiedEmailFailure(failure) ||
              _isExistingEmailFailure(failure)) {
            await _handleUnverifiedEmail(
              email: email.trim(),
              role: role,
              purpose: OtpVerificationPurpose.unverifiedSignupRetry,
            );
            return;
          }
          _showError('Sign Up Failed', _cleanAuthErrorMessage(failure.message));
        },
        (success) async {
          DPrint.log(
            'SIGNUP SUCCESS => email: ${email.trim()}, role: ${role.storageValue}',
          );
          await _authStorageService.clearAuthData();
          await _authStorageService.storeRole(role.storageValue);
          selectedRole.value = role;
          isGuestMode.value = false;

          Get.snackbar(
            'Success',
            'Account created successfully. Please verify your email.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: TColors.white,
          );

          _openOtpScreen(
            email: email.trim(),
            role: role,
            purpose: OtpVerificationPurpose.signupEmailVerification,
          );
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

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
    required OtpVerificationPurpose purpose,
    AppUserRole? role,
  }) async {
    if (isSubmitting.value) return;

    final trimmedEmail = email.trim();
    final trimmedOtp = otp.trim();
    if (trimmedEmail.isEmpty) {
      _showError('Verification Failed', 'Email is missing.');
      return;
    }
    if (trimmedOtp.length != 6) {
      _showError('Invalid OTP', 'Please enter the complete 6 digit OTP.');
      return;
    }

    isSubmitting.value = true;
    try {
      final request = VerifyMailOtpRequest(
        email: trimmedEmail,
        otp: trimmedOtp,
      );
      final result = await _authRepository.verifyOtp(request);

      await result.fold<Future<void>>(
        (failure) async {
          _showError(
            'Verification Failed',
            _cleanOtpErrorMessage(failure.message),
          );
        },
        (success) async {
          DPrint.log('OTP VERIFY SUCCESS => email: $trimmedEmail');
          Get.snackbar(
            'Success',
            success.message.isNotEmpty
                ? success.message
                : 'Email verified successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: TColors.white,
          );

          final authResponse = success.data;
          if (authResponse != null && authResponse.accessToken.isNotEmpty) {
            final resolvedRole = await _persistAuthSessionAndResolveRole(
              authResponse,
              fallbackRole: role,
            );
            Get.offAll(() => DashboardScreen(role: resolvedRole));
            return;
          }

          if (role != null) {
            selectedRole.value = role;
            await _authStorageService.storeRole(role.storageValue);
          }
          Get.offAll(() => const LoginRoleScreen());
        },
      );
    } catch (_) {
      _showError(
        'Verification Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> resendEmailOtp(String email, {bool showMessage = true}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      if (showMessage) {
        _showError('Resend OTP', 'Email is missing.');
      }
      return false;
    }

    try {
      final result = await _authRepository.resendOtp(email: trimmedEmail);

      return result.fold(
        (failure) {
          if (showMessage) {
            _showError('Resend OTP', _cleanOtpErrorMessage(failure.message));
          }
          return false;
        },
        (success) {
          DPrint.log('RESEND OTP SENT => email: $trimmedEmail');
          if (showMessage) {
            Get.snackbar(
              'OTP Sent',
              'OTP sent to your email.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: TColors.white,
            );
          }
          return true;
        },
      );
    } catch (_) {
      if (showMessage) {
        _showError('Resend OTP', 'Unable to send OTP. Please try again.');
      }
      return false;
    }
  }

  Future<void> logout() async {
    await _authStorageService.clearAuthData();
    isGuestMode.value = false;
    selectedRole.value = null;
    Get.offAll(() => const RoleSelectionScreen());
  }

  Future<void> logoutFromApi() async {
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    try {
      final result = await _authRepository.logout();
      await result.fold<Future<void>>(
        (_) async {
          await _clearSessionAndOpenRoleSelection();
        },
        (_) async {
          await _clearSessionAndOpenRoleSelection();
        },
      );
    } catch (_) {
      await _clearSessionAndOpenRoleSelection();
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> continueAsGuest() async {
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    try {
      _clearGuestSensitiveControllers();
      await _authStorageService.clearAuthData();
      const AppUserRole role = AppUserRole.user;
      await _authStorageService.storeRole(role.storageValue);
      await _authStorageService.storeGuestMode(true);
      selectedRole.value = role;
      isGuestMode.value = true;
      Get.offAll(() => DashboardScreen(role: role));
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearGuestSensitiveControllers() {
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
    if (Get.isRegistered<HomeWishlistController>()) {
      Get.delete<HomeWishlistController>(force: true);
    }
    if (Get.isRegistered<AiChatController>()) {
      Get.delete<AiChatController>(force: true);
    }
    if (Get.isRegistered<BottomNavController>(tag: 'dashboard_user')) {
      Get.delete<BottomNavController>(tag: 'dashboard_user', force: true);
    }
    if (Get.isRegistered<BottomNavController>(
      tag: 'dashboard_restaurant_owner',
    )) {
      Get.delete<BottomNavController>(
        tag: 'dashboard_restaurant_owner',
        force: true,
      );
    }
  }

  Future<void> exitGuestMode() async {
    await _authStorageService.storeGuestMode(false);
    isGuestMode.value = false;
  }

  Future<void> restoreGuestMode() async {
    _clearGuestSensitiveControllers();
    await _authStorageService.storeGuestMode(true);
    await _authStorageService.storeRole(AppUserRole.user.storageValue);
    selectedRole.value = AppUserRole.user;
    isGuestMode.value = true;
  }

  Future<bool> shouldRequireLoginForAction() async {
    if (isGuestMode.value || await _authStorageService.isGuestMode()) {
      isGuestMode.value = true;
      return true;
    }

    final accessToken = await _authStorageService.getAccessToken();
    return accessToken == null || accessToken.trim().isEmpty;
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
    await _authStorageService.storeGuestMode(false);
    isGuestMode.value = false;

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

  Future<AppUserRole?> _tryRestoreSession({
    required String refreshToken,
    required AppUserRole fallbackRole,
  }) async {
    final result = await _authRepository.refreshToken(
      RefreshTokenRequestModel(refreshToken: refreshToken),
    );

    return result.fold<Future<AppUserRole?>>(
      (_) async {
        await _authStorageService.clearAuthData();
        selectedRole.value = null;
        isGuestMode.value = false;
        return null;
      },
      (success) async {
        final String newAccessToken = success.data.accessToken.trim();
        final String newRefreshToken = success.data.refreshToken.trim();
        if (newAccessToken.isEmpty) {
          await _authStorageService.clearAuthData();
          selectedRole.value = null;
          isGuestMode.value = false;
          return null;
        }

        await _authStorageService.clearAuthData();
        await _authStorageService.storeAccessToken(newAccessToken);
        if (newRefreshToken.isNotEmpty) {
          await _authStorageService.storeRefreshToken(newRefreshToken);
        }
        await _authStorageService.storeRole(fallbackRole.storageValue);
        selectedRole.value = fallbackRole;
        isGuestMode.value = false;
        return fallbackRole;
      },
    );
  }

  Future<void> _openAuthenticatedDashboard(AppUserRole role) async {
    await _authStorageService.storeGuestMode(false);
    selectedRole.value = role;
    isGuestMode.value = false;
    Get.offAll(() => DashboardScreen(role: role));
  }

  Future<void> _clearSessionAndOpenRoleSelection() async {
    await _authStorageService.clearAuthData();
    isGuestMode.value = false;
    selectedRole.value = null;
    Get.offAll(() => const RoleSelectionScreen());
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

  Future<void> _handleUnverifiedEmail({
    required String email,
    required AppUserRole? role,
    required OtpVerificationPurpose purpose,
  }) async {
    DPrint.log('UNVERIFIED EMAIL DETECTED => email: $email');
    await _authStorageService.clearAuthData();
    if (role != null) {
      selectedRole.value = role;
      await _authStorageService.storeRole(role.storageValue);
    }
    Get.snackbar(
      'Email Verification Required',
      'Please verify your email to continue.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.white,
    );
    _openOtpScreen(email: email, role: role, purpose: purpose);
  }

  void _openOtpScreen({
    required String email,
    required AppUserRole? role,
    required OtpVerificationPurpose purpose,
  }) {
    DPrint.log(
      'OTP SCREEN OPENED => email: $email, purpose: ${purpose.logValue}',
    );
    Get.to(
      () => OTPVerificationScreen(email: email, role: role, purpose: purpose),
    );
  }

  bool _isUnverifiedEmailFailure(NetworkFailure failure) {
    final message = failure.message.toLowerCase();
    return message.contains('unverified') ||
        message.contains('not verified') ||
        message.contains('verify your email') ||
        message.contains('email verification') ||
        message.contains('email is not verify') ||
        message.contains('please verify');
  }

  bool _isExistingEmailFailure(NetworkFailure failure) {
    final message = failure.message.toLowerCase();
    return message.contains('email') &&
        (message.contains('already') || message.contains('exist'));
  }

  String _cleanAuthErrorMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return 'Something went wrong. Please try again.';
    }
    return trimmed;
  }

  String _cleanOtpErrorMessage(String message) {
    final lower = message.trim().toLowerCase();
    if (lower.isEmpty || lower.startsWith('{') || lower.startsWith('[')) {
      return 'Unable to verify OTP. Please try again.';
    }
    if (lower.contains('expired')) {
      return 'This OTP has expired. Please resend OTP and try again.';
    }
    if (lower.contains('invalid') ||
        lower.contains('incorrect') ||
        lower.contains('wrong')) {
      return 'The OTP you entered is incorrect.';
    }
    return message.trim();
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
