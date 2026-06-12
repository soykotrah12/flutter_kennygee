import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../feature/auth/presentation/controller/auth_flow_controller.dart';
import '../../../feature/auth/presentation/screens/logIn_screen.dart';
import '../../theme/app_colors.dart';

Future<bool> requireLoginForFeature({
  String featureName = 'this feature',
}) async {
  final AuthFlowController flowController = ensureAuthFlowController();
  final bool requiresLogin = await flowController.shouldRequireLoginForAction();
  if (!requiresLogin) {
    return true;
  }

  await showLoginRequiredDialog();
  return false;
}

Future<bool> requireLoginForAction(BuildContext context, {String? message}) {
  return requireLoginForFeature(featureName: message ?? 'this feature');
}

Future<void> showLoginRequiredDialog({
  String featureName = 'this feature',
}) async {
  if (Get.isDialogOpen == true) {
    return;
  }

  await Get.dialog<void>(
    Builder(
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardAdaptive,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Login Required',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          content: Text(
            'Please log in to use this feature.',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back<void>();
                Get.offAll(() => const LoginRoleScreen());
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class GuestLoginRequiredView extends StatelessWidget {
  const GuestLoginRequiredView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => const LoginRoleScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
