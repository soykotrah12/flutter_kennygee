import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common/constants/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashScreenController controller = Get.put(SplashScreenController());

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
