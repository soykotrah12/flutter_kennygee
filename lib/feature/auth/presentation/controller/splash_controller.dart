import 'package:get/get.dart';

import '../../../../core/network/services/auth_storage_service.dart';
import 'auth_flow_controller.dart';

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

    await ensureAuthFlowController().startAppFromSplash();
  }
}
