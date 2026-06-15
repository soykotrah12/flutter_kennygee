import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/bottomNavbar/controllers/bottom_nav_controller.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';
import '../controller/profile_controller.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'logout_confirm_screen.dart';
import 'profile_bookmark_screen.dart';
import 'privacy_policy_security_screen.dart';
import 'terms_of_condition_screen.dart';
import '../widgets/stripe_connect_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    debugPrint('[ProfileScreen] build count=$_buildCount');

    final flowController = ensureAuthFlowController();
    final themeController = ensureThemeController();

    return Obx(() {
      if (flowController.isGuestMode.value) {
        return AppScaffold(
          useSafeArea: true,
          isScrollable: false,
          backgroundColor: AppColors.background(context),
          body: const GuestLoginRequiredView(
            message: 'Please log in to use Profile features.',
          ),
        );
      }

      final profileController = ensureProfileController();
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
        backgroundColor: AppColors.background(context),
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
                        // Image.asset(
                        //   AppImages.appLogo,
                        //   width: 32,
                        //   height: 51,
                        //   fit: BoxFit.contain,
                        // ),
                        Image.asset(
                          AppImages.appLogo,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const Spacer(),
                        // Image.asset(
                        //   AppImages.ai,
                        //   width: 30,
                        //   height: 30,
                        //   fit: BoxFit.contain,
                        // ),
                        // const SizedBox(width: 16),
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
                    Text(
                      'Quick Access',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
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
                        Divider(color: AppColors.divider(context), height: 1),
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
                    const SizedBox(height: 12),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      children: [
                        _SettingsRow(
                          icon: AppImages.editprofile,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () => Get.to(() => const EditProfileScreen()),
                        ),
                        Divider(color: AppColors.divider(context), height: 1),
                        _SettingsRow(
                          icon: AppImages.changepassword,
                          title: 'Change Password',
                          subtitle: 'Update your personal information',
                          onTap: () =>
                              Get.to(() => const ChangePasswordScreen()),
                        ),
                        Divider(color: AppColors.divider(context), height: 1),
                        _SettingsRow(
                          icon: AppImages.privacypolicy,
                          title: 'Privacy policy & Security',
                          subtitle: 'How we handle your data',
                          onTap: () =>
                              Get.to(() => const PrivacyPolicySecurityScreen()),
                        ),
                        Divider(color: AppColors.divider(context), height: 1),
                        _SettingsRow(
                          icon: AppImages.terms,
                          title: 'Terms of Condition',
                          subtitle: 'App usage terms andiconditions',
                          onTap: () =>
                              Get.to(() => const TermsOfConditionScreen()),
                        ),
                        Divider(color: AppColors.divider(context), height: 1),
                        _SettingsRow(
                          icon: AppImages.helpsupport,
                          title: 'Help & Support',
                          subtitle: 'App usage terms and conditions',
                          onTap: () => Get.to(() => const HelpSupportScreen()),
                        ),
                        Divider(color: AppColors.divider(context), height: 1),
                        Obx(
                          () => _ThemeToggleRow(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: 'Enable dark theme for the app',
                            value: themeController.isDarkMode.value,
                            onChanged: themeController.toggleDarkMode,
                          ),
                        ),
                        Divider(color: AppColors.divider(context), height: 1),
                        _SettingsRow(
                          icon: AppImages.logout,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          onTap: profileController.confirmDeleteAccount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => Get.to(() => const LogoutConfirmScreen()),
                      child: Container(
                        height: 51,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
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
                          ? Padding(
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
    final themeController = ensureThemeController();
    profileController.onOwnerProfileOpened();

    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.background(context),
      bodyPadding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
      customAppBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 48,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.primaryText(context),
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
                      color: AppColors.cardColor(context),
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
                                  style: TextStyle(
                                    color: AppColors.primaryText(context),
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
                                  style: TextStyle(
                                    color: AppColors.secondaryText(context),
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
                  Obx(
                    () => StripeConnectCard(
                      isConnected: profileController.stripeConnected.value,
                      isLoading:
                          profileController.isStripeStatusLoading.value ||
                          profileController.isStripeOnboardingLoading.value,
                      onTap: profileController.onTapStripeConnect,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardColor(context),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.divider(context),
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
                        Divider(height: 1, color: AppColors.divider(context)),
                        _OwnerSettingsRow(
                          icon: AppImages.changepassword,
                          title: 'Change Password',
                          subtitle: 'Update your personal information',
                          onTap: () =>
                              Get.to(() => const ChangePasswordScreen()),
                        ),
                        Divider(height: 1, color: AppColors.divider(context)),
                        _OwnerSettingsRow(
                          icon: AppImages.privacypolicy,
                          title: 'Privacy policy & Security',
                          subtitle: 'How we handle your data',
                          onTap: () =>
                              Get.to(() => const PrivacyPolicySecurityScreen()),
                        ),
                        Divider(height: 1, color: AppColors.divider(context)),
                        _OwnerSettingsRow(
                          icon: AppImages.terms,
                          title: 'Terms of Condition',
                          subtitle: 'App usage terms and conditions',
                          onTap: () =>
                              Get.to(() => const TermsOfConditionScreen()),
                        ),
                        Divider(height: 1, color: AppColors.divider(context)),
                        _OwnerSettingsRow(
                          icon: AppImages.helpsupport,
                          title: 'Help & Support',
                          subtitle: 'App usage terms and conditions',
                          onTap: () => Get.to(() => const HelpSupportScreen()),
                        ),
                        Divider(height: 1, color: AppColors.divider(context)),
                        Obx(
                          () => _ThemeToggleRow(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: 'Enable dark theme for the app',
                            value: themeController.isDarkMode.value,
                            onChanged: themeController.toggleDarkMode,
                          ),
                        ),
                        Divider(height: 1, color: AppColors.divider(context)),
                        _OwnerSettingsRow(
                          icon: AppImages.logout,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          onTap: profileController.confirmDeleteAccount,
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
                      child: Row(
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
                        ? Padding(
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
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                color: AppColors.primaryText(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
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
        border: Border.all(color: AppColors.divider(context), width: 1.2),
        color: AppColors.cardColor(context),
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
              decoration: BoxDecoration(
                color: AppColors.cardColor(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context, light: 0.1, dark: 0.26),
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
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
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
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(width: 14),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.iconColor(context),
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
                    color: AppColors.primaryText(context),
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
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
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

class _ThemeToggleRow extends StatelessWidget {
  const _ThemeToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primaryText(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primaryOrange,
              inactiveThumbColor:
                  Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.primaryWhite,
              inactiveTrackColor:
                  Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF4A4A4A)
                  : AppColors.divider(context),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
