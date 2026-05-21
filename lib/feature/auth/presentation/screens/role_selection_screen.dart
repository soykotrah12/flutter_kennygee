import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowController = ensureAuthFlowController();
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;
    final titleSize = width < 370 ? 22.0 : 25.0;

    return AppScaffold(
      useSafeArea: false,
      isScrollable: false,
      bodyPadding: EdgeInsets.zero,
      backgroundColor: AppColors.appBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.rolebackground, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              topInset + 22,
              24,
              bottomInset + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  AppImages.appLogo,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 34),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Select your role to begin\n',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.45,
                          color: AppColors.textBlack,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'your journey.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.45,
                          color: AppColors.primaryGreen,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'We tailor the experience based on who you are.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    height: 1.25,
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                Obx(
                  () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _RoleCard(
                          label: 'User',
                          image: AppImages.roleUser,
                          isSelected:
                              flowController.selectedRole.value ==
                              AppUserRole.user,
                          onTap: () =>
                              flowController.selectRole(AppUserRole.user),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _RoleCard(
                          label: 'Restaurant Owner',
                          image: AppImages.roleOwner,
                          isSelected:
                              flowController.selectedRole.value ==
                              AppUserRole.restaurantOwner,
                          onTap: () => flowController.selectRole(
                            AppUserRole.restaurantOwner,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  height: 51,
                  borderRadius: 40,
                  onPressed: flowController.continueFromRoleSelection,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textBlack,
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
