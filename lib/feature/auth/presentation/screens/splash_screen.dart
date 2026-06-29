import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';

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

    if (!mounted || AuthStorageService.isClearingAfterAccountDelete) return;
    await ensureAuthFlowController().startAppFromSplash();
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
