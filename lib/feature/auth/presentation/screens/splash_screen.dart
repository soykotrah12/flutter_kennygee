import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/bottomNavbar/screens/dashboard_screen.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/network/services/onboarding_store_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';
import 'OnboardingScreen1.dart';
import 'logIn_screen.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || AuthStorageService.isClearingAfterAccountDelete) return;

    final authStorage = Get.find<AuthStorageService>();
    final onboardingStore = Get.find<OnboardingStoreService>();

    final accessToken = await authStorage.getAccessToken();
    final refreshToken = await authStorage.getRefreshToken();
    final storedRole = await authStorage.getRole();
    final isGuestMode = await authStorage.isGuestMode();
    final isOnboardingCompleted = await onboardingStore.isOnboardingCompleted();

    if (!mounted || AuthStorageService.isClearingAfterAccountDelete) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Center(
        child: Image.asset(
          AppImages.appLogo,
          width: 150,
          height: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
