import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';

class LogoutConfirmScreen extends StatelessWidget {
  const LogoutConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowController = ensureAuthFlowController();

    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 30,
                  color: AppColors.textBlack,
                ),
              ),
              const Expanded(
                child: Text(
                  'Log out',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 38),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGreen, width: 1.8),
            ),
            child: Column(
              children: [
                const Text(
                  'Are you sure to log out?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 26),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: flowController.isSubmitting.value
                              ? null
                              : Get.back,
                          child: Container(
                            height: 68,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF173D),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFFFF173D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: GestureDetector(
                          onTap: flowController.isSubmitting.value
                              ? null
                              : flowController.logoutFromApi,
                          child: Container(
                            height: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF123D),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: flowController.isSubmitting.value
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Log out',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
