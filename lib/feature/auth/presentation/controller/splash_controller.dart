import 'package:get/get.dart';

import '../../../../core/common/widgets/bottomNavbar/screens/dashboard_screen.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/network/services/onboarding_store_service.dart';
import 'auth_flow_controller.dart';
import '../screens/logIn_screen.dart';
import '../screens/OnboardingScreen1.dart';
import '../screens/role_selection_screen.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    await Future.delayed(const Duration(seconds: 2));

    if (AuthStorageService.isClearingAfterAccountDelete) {
      return;
    }

    final authStorage = Get.find<AuthStorageService>();
    final onboardingStore = Get.find<OnboardingStoreService>();

    final accessToken = await authStorage.getAccessToken();
    final refreshToken = await authStorage.getRefreshToken();
    final storedRole = await authStorage.getRole();
    final isGuestMode = await authStorage.isGuestMode();
    final isOnboardingCompleted = await onboardingStore.isOnboardingCompleted();

    final hasSession =
        (accessToken != null && accessToken.isNotEmpty) ||
        (refreshToken != null && refreshToken.isNotEmpty);

    if (hasSession) {
      await authStorage.storeGuestMode(false);
      final role = roleFromStorage(storedRole);
      Get.offAll(() => DashboardScreen(role: role));
      return;
    }

    if (isGuestMode) {
      await ensureAuthFlowController().restoreGuestMode();
      Get.offAll(() => DashboardScreen(role: AppUserRole.user));
      return;
    }

    if (isOnboardingCompleted) {
      if (storedRole != null && storedRole.isNotEmpty) {
        Get.offAll(() => const LoginRoleScreen());
      } else {
        Get.offAll(() => const RoleSelectionScreen());
      }
      return;
    }

    Get.offAll(() => const OnboardingScreen1());
  }
}
