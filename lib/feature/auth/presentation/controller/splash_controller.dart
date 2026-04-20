import 'package:get/get.dart';

import '../screens/OnboardingScreen1.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.offAll(() => const OnboardingScreen1());
  }
}
