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
      bodyPadding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
                        width: 42,
                        height: 66,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 34,
                            color: AppColors.primaryGreen,
                          ),
                          Positioned(
                            left: -14,
                            bottom: -3,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 1.4,
                          ),
                          image: const DecorationImage(
                            image: AssetImage(AppImages.ownerOnboarding1),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionCard(
                    children: [
                      _QuickAccessRow(
                        icon: Icons.favorite,
                        iconColor: AppColors.primaryOrange,
                        title: 'Favorite Food & Restaurants',
                        subtitle: 'See your Favorite Restaurants',
                        count: '12',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _QuickAccessRow(
                        icon: Icons.bookmark_border,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your personal information',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy policy & Security',
                        subtitle: 'How we handle your data',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Terms of Condition',
                        subtitle: 'App usage terms and conditions',
                      ),
                      Divider(color: Color(0xFFB9B9B9), height: 1),
                      _SettingsRow(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'App usage terms and conditions',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Get.to(() => const LogoutConfirmScreen()),
                    child: Container(
                      height: 72,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            size: 36,
                            color: Colors.white,
                          ),
                          SizedBox(width: 14),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
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

  final IconData icon;
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
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
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
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 16,
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
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.chevron_right, size: 36, color: AppColors.textBlack),
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

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Icon(icon, size: 36, color: AppColors.textBlack),
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
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 16,
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
