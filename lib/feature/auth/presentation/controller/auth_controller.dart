import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/base/base_controller.dart';
import '../../../../../core/network/services/auth_storage_service.dart';
import '../../../../../core/utils/debug_print.dart';
import '../../data/model/forgot_pass_request_model.dart';
import '../../data/model/login_request_model.dart';
import '../../data/model/refresh_token_request_model.dart';
import '../../data/model/register_request_model.dart';
import '../../data/model/set_password_request_model.dart';
import '../../data/model/verify_otp_request-model.dart';
import '../../domain/repo/auth_repo.dart';
import '../screens/logIn_screen.dart';
import '../screens/Otp_verify_screen.dart' as ForgotPasswordOtp;
import '../screens/otp_verification_screen.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepository;
  final AuthStorageService _authStorageService;

  AuthController(this._authRepository, this._authStorageService);

  Future<void> login(String email, String password) async {
    setLoading(true);
    setError("");

    DPrint.log(
      "\n╔═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 🔐 LOGIN ATTEMPT");
    DPrint.log(
      "╠═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 📧 Email: $email");
    DPrint.log("║ 🔑 Password: ${password.replaceAll(RegExp(r'.'), '*')}");
    DPrint.log(
      "╚═══════════════════════════════════════════════════════════════\n",
    );

    final request = LoginRequestModel(email: email, password: password);

    final result = await _authRepository.login(request);

    result.fold(
      (fail) {
        debugPrint("❌ API Error: ${fail.message}");
        setError(fail.message);

        // Show Snackbar on failure
        Get.snackbar(
          "Login Failed",
          fail.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );

        setLoading(false);
      },
      (success) async {
        debugPrint("✅ API Hit Successful!");

        // // Store auth data for all roles
        // await _authStorageService.storeAuthData(
        //   accessToken: success.data.accessToken,
        //   refreshToken: success.data.refreshToken,
        //   userId: success.data.user.id,
        //   role: success.data.role,
        //   userName: success.data.user.name,
        //   userAvatar: success.data.user.avatar.url,
        //   userEmail: success.data.user.email,
        //   userPhone: success.data.user.phone,
        //   shopName: success.data.user.shopName ?? '',
        // );

        // Optional: show success Snackbar
        Get.snackbar(
          "Success",
          "Logged in successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        setLoading(false);

        // Check if player has incomplete profile (empty sportPreferences)
        final isPlayerWithIncompleteProfile =
            success.data.role == 'player' &&
            (success.data.user.sportPreferences.isEmpty);

        // Check if instructor has incomplete profile (empty gender field)
        final isInstructorWithIncompleteProfile =
            success.data.role == 'instructor' &&
            (success.data.user.gender == null ||
                success.data.user.gender!.isEmpty);

        if (isPlayerWithIncompleteProfile) {
          // Player profile is incomplete - redirect to onboarding
          DPrint.log(
            "⚠️ Player profile incomplete - redirecting to PersonalInfoScreen",
          );
          DPrint.log("📋 User: ${success.data.user.name}");
          DPrint.log("🏆 Sports: ${success.data.user.sportPreferences}");

          // Get.offAll(
          //   () => PlayerPersonalInfoScreen(
          //     prefilledName: success.data.user.name,
          //     prefilledGender: '', // Empty - user needs to fill
          //     prefilledAge: 0,
          //     prefilledLocation: '',
          //     isFromLogin: true, // Flag to know it's from login
          //   ),
          // );
        } else if (isInstructorWithIncompleteProfile) {
          // Instructor profile is incomplete - redirect to onboarding
          DPrint.log(
            "⚠️ Instructor profile incomplete - redirecting to InstructorPersonalInfoScreen",
          );
          DPrint.log("📋 User: ${success.data.user.name}");
          DPrint.log("👤 Gender: ${success.data.user.gender}");

          // Get.offAll(
          //   () => InstructorPersonalInfoScreen(
          //     prefilledName: success.data.user.name,
          //     prefilledGender: '', // Empty - user needs to fill
          //     prefilledAge: 0,
          //     prefilledLocation: '',
          //     isFromLogin: true, // Flag to know it's from login
          //   ),
          // );
        } else {
          // Check if berber has incomplete profile (empty shopLogo)
          final isBarberWithIncompleteProfile =
              success.data.role == 'berber' &&
              (success.data.user.shopLogo.url.isEmpty);

          if (isBarberWithIncompleteProfile) {
            // Barber profile is incomplete - redirect to profile setup
            DPrint.log(
              "⚠️ Barber profile incomplete - redirecting to BarberProfileSetupMainScreen",
            );
            DPrint.log("📋 User: ${success.data.user.name}");
            DPrint.log("🏪 Shop Logo: ${success.data.user.shopLogo.url}");

            // TODO: Implement barber profile setup screen and uncomment below navigation
            // Get.offAll(() => const ());
          } else {
            // Navigate to dashboard for all roles with complete profiles
            // Dashboard screen will handle role-based navigation (admin/barber/user)
            DPrint.log("✅ Login successful - redirecting to Dashboard");
            DPrint.log("👤 User: ${success.data.user.name}");
            DPrint.log("🎭 Role: ${success.data.role}");

            //TODO: Implement dashboard screen and uncomment below navigation
            // Get.offAll(() => const DashboardScreen());
          }
        }
      },
    );
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String confirmPassword,
    String role, {
    String? shopName,
  }) async {
    setLoading(true);
    setError('');

    // Map frontend role to API role
    String apiRole = role == 'beardfriend' ? 'user' : 'berber';

    DPrint.log(
      "\n╔═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 📝 REGISTER ATTEMPT");
    DPrint.log(
      "╠═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 👤 Name: $name");
    DPrint.log("║ 📧 Email: $email");
    DPrint.log("║ 🎭 Frontend Role: $role");
    DPrint.log("║ 🎭 API Role: $apiRole");
    if (shopName != null) {
      DPrint.log("║ 🏪 Shop Name: $shopName");
    }
    DPrint.log(
      "╚═══════════════════════════════════════════════════════════════\n",
    );

    // Local validation first
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      setLoading(false);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Error",
        "Password and Confirm Password do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      setLoading(false);
      return;
    }

    final request = RegisterRequestModel(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      role: apiRole,
      shopName: shopName,
    );

    final result = await _authRepository.register(request);

    result.fold(
      (fail) {
        setError(fail.message);

        // Show Snackbar for API error
        Get.snackbar(
          "Error",
          fail.message.contains("email")
              ? "Email already exists"
              : fail.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );

        DPrint.log("Register failed: ${fail.message}");
        setLoading(false);
      },
      (success) async {
        DPrint.log("Register success: ${success.data.email}");

        Get.snackbar(
          "Success",
          "Account created successfully. Please verify your email.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        setLoading(false);
        Get.to(() => OTPVerificationScreen(email: email));
      },
    );
  }

  Future forgotPassword(String email) async {
    setLoading(true);
    setError('');

    DPrint.log(
      "\n╔═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 🔑 FORGOT PASSWORD REQUEST");
    DPrint.log(
      "╠═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 📧 Email: $email");
    DPrint.log(
      "╚═══════════════════════════════════════════════════════════════\n",
    );

    // Validate email
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      setLoading(false);
      return;
    }

    final request = ForgotPassRequestModel.fromJson({'email': email});
    final result = await _authRepository.forgotPassword(request);

    result.fold(
      (fail) {
        setError(fail.message);
        DPrint.log("❌ Forgot password failed: ${fail.message}");

        Get.snackbar(
          "Error",
          fail.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );

        setLoading(false);
      },
      (success) {
        DPrint.log("✅ OTP sent successfully: ${success.message}");

        Get.snackbar(
          "Success",
          "OTP sent to your email",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        setLoading(false);
        Get.to(() => ForgotPasswordOtp.OtpVerificationScreen(email: email));
      },
    );
  }

  Future verifyOTP(String email, String otp) async {
    setLoading(true);
    setError("");

    DPrint.log(
      "\n╔═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 🔢 OTP VERIFICATION ATTEMPT");
    DPrint.log(
      "╠═══════════════════════════════════════════════════════════════",
    );
    DPrint.log("║ 📧 Email: $email");
    DPrint.log("║ 🔑 OTP: ${otp.replaceAll(RegExp(r'.'), '*')}");
    DPrint.log(
      "╚═══════════════════════════════════════════════════════════════\n",
    );

    // Validate inputs
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Email is missing",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      setLoading(false);
      return;
    }

    if (otp.isEmpty || otp.length < 4) {
      Get.snackbar(
        "Error",
        "Please enter a valid OTP",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      setLoading(false);
      return;
    }

    final request = VerifyMailOtpRequest(email: email, otp: otp);
    final result = await _authRepository.verifyOtp(request);

    result.fold(
      (fail) {
        setError(fail.message);
        DPrint.log("❌ OTP verification failed: ${fail.message}");

        Get.snackbar(
          "Error",
          fail.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );

        setLoading(false);
      },
      (success) {
        DPrint.log("✅ OTP verified successfully: ${success.message}");

        Get.snackbar(
          "Success",
          "OTP verified successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        setLoading(false);
        Get.offAll(() => const LoginRoleScreen());
      },
    );
  }

  Future setNewPass(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    setLoading(true);
    setError("");

    // Validate passwords
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter passwords",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      setLoading(false);
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      setLoading(false);
      return;
    }

    final request = ResetPasswordRequestModel(
      email: email,
      otp: otp,
      password: newPassword,
      confirmPassword: confirmPassword,
    );
    final result = await _authRepository.setNewPassword(request);

    result.fold(
      (fail) {
        setError(fail.message);
        DPrint.log("❌ Set new password failed: ${fail.message}");

        Get.snackbar(
          "Error",
          fail.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );

        setLoading(false);
      },
      (success) {
        DPrint.log("✅ Password set successfully: ${success.message}");

        Get.snackbar(
          "Success",
          success.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        setLoading(false);
        Get.offAll(
          () => const LoginRoleScreen(),
          transition: Transition.leftToRight,
        );
      },
    );
  }

  Future<bool> refreshToken() async {
    // setLoading(true); // Don't show loading on splash

    final refreshToken = await _authStorageService.getRefreshToken();
    DPrint.log("🐞 DEBUG: Got refresh token: $refreshToken");

    if (refreshToken == null || refreshToken.isEmpty) {
      DPrint.log("❌ No refresh token stored");
      setLoading(false);
      return false; // Return false instead of navigating
    }

    final request = RefreshTokenRequestModel(refreshToken: refreshToken);
    final result = await _authRepository.refreshToken(request);

    return result.fold(
      (fail) async {
        DPrint.log("❌ Refresh token failed: ${fail.message}");
        await _authStorageService.clearAuthData(); // clear invalid token
        setLoading(false);
        return false; // Return false instead of navigating
      },
      (success) async {
        DPrint.log("✅ Refresh token success: ${success.message}");
        await _authStorageService.storeAccessToken(success.data.accessToken);
        await _authStorageService.storeRefreshToken(success.data.refreshToken);
        setLoading(false);
        return true; // Return true instead of navigating
      },
    );
  }

  Future<void> logout() async {
    await _authStorageService.clearAuthData();
    Get.offAll(() => const LoginRoleScreen());
  }
}
