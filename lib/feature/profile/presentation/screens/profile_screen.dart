import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/bottomNavbar/controllers/bottom_nav_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';
import '../controller/profile_controller.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'logout_confirm_screen.dart';
import 'profile_bookmark_screen.dart';
import 'privacy_policy_security_screen.dart';
import 'terms_of_condition_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowController = ensureAuthFlowController();
    final profileController = ensureProfileController();

    return Obx(() {
      final AppUserRole? selectedRole = flowController.selectedRole.value;
      final String profileRole = profileController.profile.value?.role ?? '';
      final bool isOwner =
          (selectedRole?.isOwner ?? false) ||
          roleFromStorage(profileRole).isOwner;

      if (isOwner) {
        return _OwnerProfileView(
          flowController: flowController,
          profileController: profileController,
        );
      }

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
                        const SizedBox(width: 16),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Obx(() {
                              final imageUrl =
                                  profileController
                                      .profile
                                      .value
                                      ?.profileImage
                                      .url ??
                                  '';

                              if (imageUrl.isNotEmpty) {
                                return Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    AppImages.defaultProfileImage,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }

                              return Image.asset(
                                AppImages.defaultProfileImage,
                                fit: BoxFit.cover,
                              );
                            }),
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
                    _SectionCard(
                      children: [
                        _QuickAccessRow(
                          icon: AppImages.wishlist,
                          iconColor: AppColors.primaryOrange,
                          title: 'Favorite Food & Restaurants',
                          subtitle: 'See your Favorite Restaurants',
                          count: profileController.totalWishlist.value
                              .toString(),
                          onTap: () {
                            final AppUserRole role =
                                flowController.selectedRole.value ??
                                roleFromStorage(profileRole);
                            final String dashboardTag =
                                'dashboard_${role.storageValue}';

                            if (Get.isRegistered<BottomNavController>(
                              tag: dashboardTag,
                            )) {
                              Get.find<BottomNavController>(
                                tag: dashboardTag,
                              ).changeIndex(2);
                            }
                          },
                        ),
                        Divider(color: Color(0xFFB9B9B9), height: 1),
                        _QuickAccessRow(
                          icon: AppImages.bookmark,
                          iconColor: AppColors.primaryOrange,
                          title: 'Book Mark',
                          subtitle: 'See your Bookmark Resturent',
                          count: profileController.totalBookmarks.value
                              .toString(),
                          onTap: () =>
                              Get.to(() => const ProfileBookmarkScreen()),
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
                    _SectionCard(
                      children: [
                        _SettingsRow(
                          icon: AppImages.editprofile,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () => Get.to(() => const EditProfileScreen()),
                        ),
                        Divider(color: Color(0xFFB9B9B9), height: 1),
                        _SettingsRow(
                          icon: AppImages.changepassword,
                          title: 'Change Password',
                          subtitle: 'Update your personal information',
                          onTap: () =>
                              Get.to(() => const ChangePasswordScreen()),
                        ),
                        Divider(color: Color(0xFFB9B9B9), height: 1),
                        _SettingsRow(
                          icon: AppImages.privacypolicy,
                          title: 'Privacy policy & Security',
                          subtitle: 'How we handle your data',
                          onTap: () =>
                              Get.to(() => const PrivacyPolicySecurityScreen()),
                        ),
                        Divider(color: Color(0xFFB9B9B9), height: 1),
                        _SettingsRow(
                          icon: AppImages.terms,
                          title: 'Terms of Condition',
                          subtitle: 'App usage terms andiconditions',
                          onTap: () =>
                              Get.to(() => const TermsOfConditionScreen()),
                        ),
                        Divider(color: Color(0xFFB9B9B9), height: 1),
                        _SettingsRow(
                          icon: AppImages.helpsupport,
                          title: 'Help & Support',
                          subtitle: 'App usage terms and conditions',
                          onTap: () => Get.to(() => const HelpSupportScreen()),
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
                            Icon(Icons.logout, size: 20, color: Colors.white),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
    });
  }
}

class _OwnerProfileView extends StatelessWidget {
  const _OwnerProfileView({
    required this.flowController,
    required this.profileController,
  });

  final AuthFlowController flowController;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
      customAppBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 48,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 1,
                      ),
                    ),
                    child: Obx(() {
                      final profile = profileController.profile.value;
                      final imageUrl = profile?.profileImage.url ?? '';

                      return Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGreen,
                                width: 0.8,
                              ),
                            ),
                            child: ClipOval(
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        AppImages.defaultProfileImage,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      AppImages.defaultProfileImage,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.name.isNotEmpty == true
                                      ? profile!.name
                                      : 'User Name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile?.email.isNotEmpty == true
                                      ? profile!.email
                                      : 'example@email.com',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFFB9B9B9),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _OwnerSettingsRow(
                          icon: AppImages.editprofile,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () => Get.to(() => const EditProfileScreen()),
                        ),
                        const Divider(height: 1, color: Color(0xFFB9B9B9)),
                        _OwnerSettingsRow(
                          icon: AppImages.changepassword,
                          title: 'Change Password',
                          subtitle: 'Update your personal information',
                          onTap: () =>
                              Get.to(() => const ChangePasswordScreen()),
                        ),
                        const Divider(height: 1, color: Color(0xFFB9B9B9)),
                        _OwnerSettingsRow(
                          icon: AppImages.privacypolicy,
                          title: 'Privacy policy & Security',
                          subtitle: 'How we handle your data',
                          onTap: () =>
                              Get.to(() => const PrivacyPolicySecurityScreen()),
                        ),
                        const Divider(height: 1, color: Color(0xFFB9B9B9)),
                        _OwnerSettingsRow(
                          icon: AppImages.terms,
                          title: 'Terms of Condition',
                          subtitle: 'App usage terms and conditions',
                          onTap: () =>
                              Get.to(() => const TermsOfConditionScreen()),
                        ),
                        const Divider(height: 1, color: Color(0xFFB9B9B9)),
                        _OwnerSettingsRow(
                          icon: AppImages.helpsupport,
                          title: 'Help & Support',
                          subtitle: 'App usage terms and conditions',
                          onTap: () => Get.to(() => const HelpSupportScreen()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),

                  GestureDetector(
                    onTap: () => Get.to(() => const LogoutConfirmScreen()),
                    child: Container(
                      height: 51,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.logoutRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 28, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                              height: 16,
                              width: 16,
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

class _OwnerSettingsRow extends StatelessWidget {
  const _OwnerSettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(icon, fit: BoxFit.contain),
            ),
            const SizedBox(width: 8),
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
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textGrey,
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
    this.onTap,
  });

  final String icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textBlack,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}
