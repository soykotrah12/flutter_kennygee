import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';
import 'logout_confirm_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowController = ensureAuthFlowController();

    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
            children: [
              Image.asset(
                AppImages.appLogo,
                width: 32,
                height: 51,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              Image.asset(
                AppImages.ai,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Container(
  width: 44,
  height: 44,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: AppColors.primaryGreen, 
      width: 2,
    ),
  ),
  child: ClipOval(
    child: Image.asset(
      AppImages.defaultProfileImage, 
      fit: BoxFit.cover,
    ),
  ),
),
            ],
          ),
          const SizedBox(height: 16),
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionCard(
                    children: [
                      _QuickAccessRow(
                        icon: AppImages.wishlist,
                        iconColor: AppColors.primaryOrange,
                        title: 'Favorite Food & Restaurants',
                        subtitle: 'See your Favorite Restaurants',
                        count: '12',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _QuickAccessRow(
                        icon: AppImages.bookmark,
                        iconColor: AppColors.primaryOrange,
                        title: 'Book Mark',
                        subtitle: 'See your Bookmark Resturent',
                        count: '12',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionCard(
                    children: [
                      _SettingsRow(
                        icon: AppImages.editprofile,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: AppImages.changepassword,
                        title: 'Change Password',
                        subtitle: 'Update your personal information',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: AppImages.privacypolicy,
                        title: 'Privacy policy & Security',
                        subtitle: 'How we handle your data',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: AppImages.terms,
                        title: 'Terms of Condition',
                        subtitle: 'App usage terms andiconditions',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: AppImages.helpsupport,
                        title: 'Help & Support',
                        subtitle: 'App usage terms and conditions',
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                  GestureDetector(
                    onTap: () => Get.to(() => const LogoutConfirmScreen()),
                    child: Container(
                      height: 51,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => flowController.isSubmitting.value
                        ? const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
      ),
      child: Column(children: children),
    );
  }
}

class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 6,
        spreadRadius: 2,
        offset: Offset(0, 2),
      ),
              ],
            ),
            child: Center(
              child: Image.asset(
                icon,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textBlack),
        ],
      ), 
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  
  final String title;
  final String subtitle;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    SizedBox(
      width: 40,
      child: SizedBox(
  width: 40,
  child: Center(
    child: Image.asset(
      icon,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    ),
  ),
),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
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
