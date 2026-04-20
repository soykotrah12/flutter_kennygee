import 'package:get/get.dart';

import '../screens/OnboardingScreen1.dart';
import 'auth_controller.dart';

class SplashScreenController extends GetxController {
  final _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Splash delay
    await Future.delayed(const Duration(seconds: 2));

    // Try to refresh token (checks if user has valid refresh token saved)
    final success = await _authController.refreshToken();

    if (success) {
      // TODO: Implement dashboard screen and uncomment below navigation
      // Get.offAll(() => const DashboardScreen());
    } else {
      // TODO: Implement onboarding flow and uncomment below navigation
      // Get.offAll(() => const OnboardingScreen1());
    }
  }
}
