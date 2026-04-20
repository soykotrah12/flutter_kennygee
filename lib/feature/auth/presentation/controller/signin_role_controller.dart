// // import 'dart:convert';
// // import 'package:flutter_lakshman1020/features/auth/users/presentation/controller/auth_controller.dart';
// // import 'package:flutter_lakshman1020/features/auth/users/presentation/screens/LogIn_screen.dart';
// // import 'package:flutter_lakshman1020/features/auth/users/presentation/screens/sign_up_screen.dart';
// // import 'package:flutter_lakshman1020/features/company_subscription_plans/presentation/screens/subscription_screen.dart';
// // import 'package:flutter_lakshman1020/features/home/presentations/screens/user_home_screen.dart';
// // import 'package:flutter_lakshman1020/core/network/services/auth_storage_service.dart';
// // import 'package:flutter_lakshman1020/core/utils/debug_print.dart';
// // import 'package:get/get.dart';

// // class SignInRoleController extends GetxController {
// //   final AuthController _authController = Get.find<AuthController>();
// //   final AuthStorageService _authStorageService = Get.find<AuthStorageService>();

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     _checkLoginStatus();
// //   }

// //   Future<void> _checkLoginStatus() async {
// //     await Future.delayed(const Duration(seconds: 2)); // splash delay

// //     final refreshToken = await _authStorageService.getRefreshToken();
// //     final role = await _authStorageService.getRole();

// //     DPrint.log("💾 Stored refresh token: $refreshToken");
// //     DPrint.log("💾 Stored role: $role");

// //     if (refreshToken == null || refreshToken.isEmpty) {
// //       _goToLogin();
// //       return;
// //     }

// //     if (_isTokenExpired(refreshToken)) {
// //       DPrint.log("❌ Refresh token expired. Redirecting to login.");
// //       await _authStorageService.clearAuthData();
// //       _goToLogin();
// //       return;
// //     }

// //     DPrint.log("🔄 Refresh token valid. Calling API...");
// //     await _authController.refreshToken(); // navigation handled inside AuthController
// //   }

// //   bool _isTokenExpired(String token) {
// //     try {
// //       final parts = token.split('.');
// //       if (parts.length != 3) return true;

// //       final payload = base64Url.normalize(parts[1]);
// //       final decoded = utf8.decode(base64Url.decode(payload));
// //       final map = json.decode(decoded);
// //       final exp = map['exp'] as int;
// //       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
// //       return now >= exp;
// //     } catch (_) {
// //       return true;
// //     }
// //   }

// //   void _goToLogin() {
// //     Get.offAll(() => SignupScreen());
// //   }
// // }

// // import 'dart:convert';
// // import 'package:flutter_lakshman1020/features/auth/users/presentation/controller/auth_controller.dart';
// // import 'package:flutter_lakshman1020/features/auth/users/presentation/screens/LogIn_screen.dart';
// // import 'package:flutter_lakshman1020/features/auth/users/presentation/screens/SignInRoleScreen.dart';
// // import 'package:flutter_lakshman1020/features/auth/users/presentation/screens/sign_up_screen.dart';
// // import 'package:flutter_lakshman1020/features/company_subscription_plans/presentation/screens/subscription_screen.dart';
// // import 'package:flutter_lakshman1020/features/home/presentations/screens/user_home_screen.dart';
// // import 'package:flutter_lakshman1020/core/network/services/auth_storage_service.dart';
// // import 'package:flutter_lakshman1020/core/utils/debug_print.dart';
// // import 'package:get/get.dart';

// // class SignInRoleController extends GetxController {
// //   final AuthController _authController = Get.find<AuthController>();
// //   final AuthStorageService _authStorageService = Get.find<AuthStorageService>();

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     _checkLoginStatus();
// //   }

// //   Future<void> _checkLoginStatus() async {
// //     final refreshToken = await _authStorageService.getRefreshToken();
// //     final role = await _authStorageService.getRole();

// //     DPrint.log("💾 Stored refresh token: $refreshToken");
// //     DPrint.log("💾 Stored role: $role");

// //     if (refreshToken == null || refreshToken.isEmpty) {
// //       // First-time user: go directly to signup/role selection
// //       DPrint.log("❌ No refresh token found. First-time user, show signup.");
// //       _goToSignup();
// //       return;
// //     }

// //     // Returning user: add delay for splash/loading effect
// //     await Future.delayed(const Duration(seconds: 2));

// //     if (_isTokenExpired(refreshToken)) {
// //       DPrint.log("❌ Refresh token expired. Redirecting to login.");
// //       await _authStorageService.clearAuthData();
// //       _goToSignup();
// //       return;
// //     }

// //     DPrint.log("🔄 Refresh token valid. Calling API...");
// //     await _authController.refreshToken(); // navigation handled inside AuthController
// //   }

// //   bool _isTokenExpired(String token) {
// //     try {
// //       final parts = token.split('.');
// //       if (parts.length != 3) return true;

// //       final payload = base64Url.normalize(parts[1]);
// //       final decoded = utf8.decode(base64Url.decode(payload));
// //       final map = json.decode(decoded);
// //       final exp = map['exp'] as int;
// //       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
// //       return now >= exp;
// //     } catch (_) {
// //       return true;
// //     }
// //   }

// //   void _goToSignup() {
// //     Get.offAll(() => SignInRoleScreen()); // or LoginRoleScreen if you want
// //   }
// // }

// import 'dart:convert';
// import 'package:flutter_lakshman1020/features/auth/users/presentation/controller/auth_controller.dart';
// import 'package:flutter_lakshman1020/features/auth/users/presentation/screens/SignInRoleScreen.dart';
// import 'package:flutter_lakshman1020/features/company_subscription_plans/presentation/screens/subscription_screen.dart';
// import 'package:flutter_lakshman1020/features/home/presentations/screens/user_home_screen.dart';
// import 'package:flutter_lakshman1020/core/network/services/auth_storage_service.dart';
// import 'package:flutter_lakshman1020/core/utils/debug_print.dart';
// import 'package:get/get.dart';

// class SignInRoleController extends GetxController {
//   final AuthController _authController = Get.find<AuthController>();
//   final AuthStorageService _authStorageService = Get.find<AuthStorageService>();

//   @override
//   void onInit() {
//     super.onInit();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     final refreshToken = await _authStorageService.getRefreshToken();
//     final role = await _authStorageService.getRole();

//     DPrint.log("💾 Stored refresh token: $refreshToken");
//     DPrint.log("💾 Stored role: $role");

//     if (refreshToken == null || refreshToken.isEmpty) {
//       // First-time user: no delay, show role selection/signup
//       DPrint.log("First-time user, show SignInRoleScreen immediately.");
//       _goToSignup();
//       return;
//     }

//     // Returning user: add delay for splash/loading effect
//     DPrint.log("🔄 Returning user, adding splash delay...");
//     await Future.delayed(const Duration(seconds: 2));

//     DPrint.log("🔄 Refresh token valid. Calling API...");
//     // await _authController.refreshToken(); // navigation handled inside AuthController
//   }

//   void _goToSignup() {
//     Get.offAll(() => SignInRoleScreen());
//   }
// }
